//
//  WorkoutView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI
import CoreData
import PhotosUI

// MARK: - 選択された種目の情報を保持するための構造体
struct SelectedExercise: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
}

struct WorkoutView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddWorkout = false
    @State private var selectedDate = Date()
    @State private var calendarDate = Date() // カレンダー表示用の日付
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var dailyPhoto: Data?
    @State private var showingPhotoDetail = false
    
    // sheet(item:)を使用するために変更
    @State private var selectedExercise: SelectedExercise?
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: true),
            NSSortDescriptor(keyPath: \WorkoutEntry.exerciseName, ascending: true)
        ],
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
                                    print("=== 種目選択デバッグ ===")
                                    print("選択された種目名: '\(exerciseName)'")
                                    print("workoutSets数: \(workoutSets.count)")
                                    print("選択日: \(selectedDate)")
                                    
                                    // 種目名が有効な場合のみ SelectedExercise を作成
                                    if !exerciseName.isEmpty && exerciseName != "不明な種目" {
                                        selectedExercise = SelectedExercise(name: exerciseName, date: selectedDate)
                                        print("selectedExercise作成: '\(exerciseName)'")
                                    } else {
                                        print("❌ 種目名が無効のため編集をスキップ: '\(exerciseName)'")
                                    }
                                    print("========================")
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
                // 日付が変更されたらselectedExerciseをリセット
                selectedExercise = nil
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
            // sheet(item:)を使用して修正
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(
                    exerciseName: exercise.name,
                    selectedDate: exercise.date,
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
        
        print("=== WorkoutView groupedWorkouts デバッグ ===")
        print("選択日: \(selectedDate)")
        print("開始時刻: \(startOfDay)")
        print("終了時刻: \(endOfDay)")
        print("全ワークアウト数: \(workouts.count)")
        
        let filteredWorkouts = workouts.filter { workout in
            let isInRange = workout.date >= startOfDay && workout.date < endOfDay
            if isInRange {
                print("✅ マッチした記録: '\(workout.exerciseName ?? "nil")', 日時: \(workout.date)")
            }
            return isInRange
        }
        
        print("フィルタ後の記録数: \(filteredWorkouts.count)")
        
        // セットの順番を保持するために、日時順でソート
        let sortedWorkouts = filteredWorkouts.sorted { $0.date < $1.date }
        
        // 種目名が空やnilの場合の対処を強化
        let grouped = Dictionary(grouping: sortedWorkouts) { workout in
            let exerciseName = workout.exerciseName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if exerciseName.isEmpty {
                print("⚠️ 警告: 種目名が空またはnil")
                return "不明な種目"
            }
            print("グループ化: '\(exerciseName)'")
            return exerciseName
        }
        
        print("グループ化結果: \(grouped.keys.sorted())")
        print("=========================================")
        
        return grouped
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
