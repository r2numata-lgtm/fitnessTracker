//
//  WorkoutView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI
import CoreData
import PhotosUI

struct WorkoutView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddWorkout = false
    @State private var selectedDate = Date()
    @State private var calendarDate = Date() // カレンダー表示用の日付
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var dailyPhoto: Data?
    @State private var showingPhotoDetail = false
    @State private var showingExerciseDetail = false
    @State private var selectedExercise = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: false)],
        animation: .default)
    private var workouts: FetchedResults<WorkoutEntry>
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 8) {
                    // 上部：スクロール可能なカレンダーと写真セクション
                    VStack(spacing: 0) {
                        // スクロール可能なカレンダー
                        ScrollableCalendarView(
                            selectedDate: $selectedDate,
                            calendarDate: $calendarDate
                        )
                        .padding(.horizontal)
                        
                        // その日の写真セクション（コンパクト版）
                        HStack {
                            Text("今日の筋トレ写真")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if let photoData = dailyPhoto,
                               let uiImage = UIImage(data: photoData) {
                                Button(action: {
                                    showingPhotoDetail = true
                                }) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            } else {
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.blue)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .background(Color(.systemBackground))
                    
                    // 記録リスト
                    List {
                        ForEach(Array(groupedWorkouts.keys.sorted()), id: \.self) { exerciseName in
                            if let workoutSets = groupedWorkouts[exerciseName] {
                                Button(action: {
                                    selectedExercise = exerciseName
                                    showingExerciseDetail = true
                                }) {
                                    GroupedWorkoutRowView(exerciseName: exerciseName, workoutSets: workoutSets)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .onDelete(perform: deleteWorkoutGroup)
                    }
                    .listStyle(PlainListStyle())
                }
                
                // 右下の記録ボタン
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddWorkout = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 56, height: 56)
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("TODAY") {
                        let today = Date()
                        selectedDate = today      // 選択日を今日に設定
                        calendarDate = today      // カレンダー表示も今日の月に移動
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                loadDailyPhoto()
            }
            .onChange(of: selectedDate) { _ in
                loadDailyPhoto()
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        dailyPhoto = data
                        saveDailyPhoto(data)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingPhotoDetail) {
                PhotoDetailView(photoData: dailyPhoto) {
                    showingPhotoDetail = false
                }
            }
            .sheet(isPresented: $showingExerciseDetail) {
                ExerciseDetailView(
                    exerciseName: selectedExercise,
                    selectedDate: selectedDate,
                    isEditMode: true
                )
                .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    // MARK: - Private Methods
    
    // ナビゲーションタイトル用の計算プロパティ（カレンダー表示日付を使用）
    private var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: calendarDate)
    }
    
    private func loadDailyPhoto() {
        // TODO: 実際の実装では Core Data から日付ごとの写真を取得
        // 現在は仮実装
        dailyPhoto = nil
    }
    
    private func saveDailyPhoto(_ photoData: Data) {
        // TODO: 実際の実装では Core Data に日付ごとの写真を保存
        // 現在は仮実装（メモリ上にのみ保存）
        print("写真を保存しました: \(selectedDate)")
    }
    
    private var groupedWorkouts: [String: [WorkoutEntry]] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let filteredWorkouts = workouts.filter { workout in
            workout.date >= startOfDay && workout.date < endOfDay
        }
        
        return Dictionary(grouping: filteredWorkouts) { workout in
            workout.exerciseName ?? ""
        }
    }
    
    private func deleteWorkoutGroup(offsets: IndexSet) {
        withAnimation {
            let sortedExerciseNames = Array(groupedWorkouts.keys.sorted())
            for index in offsets {
                if let exerciseName = sortedExerciseNames[safe: index],
                   let workoutsToDelete = groupedWorkouts[exerciseName] {
                    for workout in workoutsToDelete {
                        viewContext.delete(workout)
                    }
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("削除エラー: \(error)")
            }
        }
    }
    
    private func deleteWorkout(offsets: IndexSet) {
        // 旧版の削除関数（使用されていないが残しておく）
        withAnimation {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: selectedDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let filteredWorkouts = workouts.filter { workout in
                workout.date >= startOfDay && workout.date < endOfDay
            }
            
            offsets.map { filteredWorkouts[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("削除エラー: \(error)")
            }
        }
    }
}

// MARK: - スクロール可能なカレンダーコンポーネント
struct ScrollableCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var calendarDate: Date
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 12) {
            // カレンダーグリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // 曜日ヘッダー
                ForEach(weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(height: 20)
                }
                
                // 日付セル
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDate(date, inSameDayAs: Date()),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        // 右へスワイプ - 前の月
                        changeMonth(-1)
                    } else if value.translation.width < -50 {
                        // 左へスワイプ - 次の月
                        changeMonth(1)
                    }
                }
        )
        .onAppear {
            currentMonth = calendarDate
        }
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        // 日曜日を最初に移動
        return Array(symbols.suffix(from: 1)) + [symbols[0]]
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)!.start
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)!.end
        
        let startOfCalendar = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)!.start
        let endOfCalendar = calendar.date(byAdding: .day, value: 6 * 7 - 1, to: startOfCalendar)!
        
        var days: [Date?] = []
        var currentDate = startOfCalendar
        
        while currentDate <= endOfCalendar {
            if currentDate >= startOfMonth && currentDate < endOfMonth {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
    private func changeMonth(_ direction: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let newMonth = calendar.date(byAdding: .month, value: direction, to: currentMonth) {
                currentMonth = newMonth
                calendarDate = newMonth
            }
        }
    }
}

// MARK: - 日付セルコンポーネント
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            Text(dayNumber)
                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                .foregroundColor(foregroundColor)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary.opacity(0.5)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else {
            return .clear
        }
    }
}

// MARK: - Array Extension for Safe Index Access
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - グループ化された筋トレ行表示
struct GroupedWorkoutRowView: View {
    let exerciseName: String
    let workoutSets: [WorkoutEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exerciseName)
                    .font(.headline)
                Spacer()
                Text("\(Int(totalCalories))kcal")
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(workoutSets.enumerated()), id: \.offset) { index, workout in
                    HStack {
                        Label("\(Int(workout.weight))kg", systemImage: "scalemass")
                        Label("\(workout.reps)回", systemImage: "number")
                        if let memo = workout.memo, !memo.isEmpty {
                            Text("(\(memo))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(Int(workout.caloriesBurned))kcal")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("合計: \(workoutSets.count)セット")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var totalCalories: Double {
        workoutSets.reduce(0) { $0 + $1.caloriesBurned }
    }
}

// MARK: - 単一筋トレ行表示（後方互換性のため残す）
struct WorkoutRowView: View {
    let workout: WorkoutEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.exerciseName ?? "")
                    .font(.headline)
                Spacer()
                Text("\(Int(workout.caloriesBurned))kcal")
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Label("\(Int(workout.weight))kg", systemImage: "scalemass")
                Label("\(workout.sets)セット", systemImage: "repeat")
                Label("\(workout.reps)回", systemImage: "number")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - 写真詳細表示画面
struct PhotoDetailView: View {
    let photoData: Data?
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let photoData = photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        onDismiss()
                    }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button("完了") {
                        onDismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                Spacer()
            }
        }
    }
}
