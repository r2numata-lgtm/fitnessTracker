//
//  ExerciseDetailView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI
import CoreData

// MARK: - 種目詳細記録画面
struct ExerciseDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let exerciseName: String
    let selectedDate: Date
    let isEditMode: Bool
    
    @State private var sets: [ExerciseSet] = [ExerciseSet()]
    @State private var showingDeleteAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // 編集モード用
    @FetchRequest private var existingWorkouts: FetchedResults<WorkoutEntry>
    
    init(exerciseName: String, selectedDate: Date, isEditMode: Bool = false) {
        self.exerciseName = exerciseName
        self.selectedDate = selectedDate
        self.isEditMode = isEditMode
        
        // 編集モードの場合、その日のその種目の記録を取得
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        self._existingWorkouts = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: true)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "exerciseName == %@", exerciseName),
                NSPredicate(format: "date >= %@", startOfDay as NSDate),
                NSPredicate(format: "date < %@", endOfDay as NSDate)
            ])
        )
    }
    
    #if DEBUG
    private func debugCurrentState() {
        print("=== ExerciseDetailView Debug ===")
        print("種目名: \(exerciseName)")
        print("選択日: \(selectedDate)")
        print("編集モード: \(isEditMode)")
        print("既存ワークアウト数: \(existingWorkouts.count)")
        for (index, workout) in existingWorkouts.enumerated() {
            print("* 既存[\(index)]: 重量=\(workout.weight), 回数=\(workout.reps)")
        }
        print("==============================")
    }
    #endif
    
    private func loadExistingSets() {
        guard isEditMode && !existingWorkouts.isEmpty else { return }
        
        sets = existingWorkouts.map { workout in
            ExerciseSet(
                weight: workout.weight,
                reps: Int(workout.reps),
                memo: workout.memo ?? ""
            )
        }
        
        #if DEBUG
        debugCurrentState()
        #endif
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("セット記録")) {
                    ForEach(sets.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("セット \(index + 1)")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("重量 (kg)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("0", value: $sets[index].weight, format: .number)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("回数")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("0", value: $sets[index].reps, format: .number)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("メモ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("メモを入力（任意）", text: $sets[index].memo)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            if sets.count > 1 {
                                Button(action: {
                                    sets.remove(at: index)
                                }) {
                                    HStack {
                                        Image(systemName: "minus.circle.fill")
                                        Text("このセットを削除")
                                    }
                                    .foregroundColor(.red)
                                    .font(.caption)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        sets.append(ExerciseSet())
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("セットを追加")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("消費カロリー")) {
                    HStack {
                        Text("合計消費カロリー")
                        Spacer()
                        Text("\(calculateTotalCalories())kcal")
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                    }
                }
                
                Section {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("この種目を削除")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadExistingSets()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "更新" : "保存") {
                        saveWorkout()
                    }
                    .disabled(sets.isEmpty || sets.allSatisfy { $0.weight == 0 && $0.reps == 0 })
                }
            }
            .alert("種目削除の確認", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    deleteExerciseFromDatabase()
                }
            } message: {
                Text("この種目を削除すると、今までのすべての記録も削除されます。この操作は取り消せません。")
            }
            .alert("エラー", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func calculateTotalCalories() -> Int {
        // MET値による消費カロリー計算
        let metValues: [String: Double] = [
            "ベンチプレス": 6.0,
            "スクワット": 5.0,
            "デッドリフト": 6.0,
            "懸垂": 8.0,
            "腕立て伏せ": 3.8,
            "ランニング": 8.0,
            "ウォーキング": 3.5
        ]
        
        let metValue = metValues[exerciseName] ?? 5.0
        let bodyWeight = 70.0 // 仮の体重
        let totalReps = sets.reduce(0) { $0 + $1.reps }
        let durationHours = Double(totalReps) / 100.0
        
        return Int(metValue * bodyWeight * durationHours)
    }
    
    private func saveWorkout() {
        // 編集モードの場合、既存のデータを削除
        if isEditMode {
            for workout in existingWorkouts {
                viewContext.delete(workout)
            }
        }
        
        // 新しいデータを保存
        for set in sets {
            let newWorkout = WorkoutEntry(context: viewContext)
            newWorkout.date = selectedDate
            newWorkout.exerciseName = exerciseName
            newWorkout.weight = set.weight
            newWorkout.sets = 1 // 1セットずつ保存
            newWorkout.reps = Int16(set.reps)
            newWorkout.caloriesBurned = Double(calculateTotalCalories()) / Double(sets.count)
            newWorkout.memo = set.memo
        }
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
    
    private func deleteExerciseFromDatabase() {
        // この種目のすべての記録を削除
        let fetchRequest: NSFetchRequest<WorkoutEntry> = WorkoutEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseName == %@", exerciseName)
        
        do {
            let workoutsToDelete = try viewContext.fetch(fetchRequest)
            for workout in workoutsToDelete {
                viewContext.delete(workout)
            }
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "削除に失敗しました: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}

// MARK: - ExerciseSet データ構造
struct ExerciseSet {
    var weight: Double = 0
    var reps: Int = 0
    var memo: String = ""
}
