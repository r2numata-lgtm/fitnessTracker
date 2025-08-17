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
    
    private func loadExistingSets() {
        if !existingWorkouts.isEmpty {
            sets = existingWorkouts.map { workout in
                ExerciseSet(
                    weight: workout.weight,
                    reps: Int(workout.reps),
                    memo: workout.memo ?? ""
                )
            }
        }
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
                
                // デバッグ情報
                Section(header: Text("デバッグ情報")) {
                    Text("種目名: '\(exerciseName)'")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("日付: \(selectedDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("既存記録数: \(existingWorkouts.count)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if isEditMode {
                    Section {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("この日の記録を削除")
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle(exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if isEditMode {
                    loadExistingSets()
                }
                debugCurrentState()
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
            .alert("記録削除の確認", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    deleteWorkoutEntries()
                }
            } message: {
                Text("この日の\(exerciseName)の記録を削除します。この操作は取り消せません。")
            }
        }
    }
    
    // デバッグ関数
    private func debugCurrentState() {
        print("=== ExerciseDetailView Debug ===")
        print("種目名: '\(exerciseName)'")
        print("選択日: \(selectedDate)")
        print("編集モード: \(isEditMode)")
        print("既存ワークアウト数: \(existingWorkouts.count)")
        
        for (index, workout) in existingWorkouts.enumerated() {
            print("  既存[\(index)]: 種目='\(workout.exerciseName ?? "nil")', 重量=\(workout.weight), 回数=\(workout.reps)")
        }
        print("==============================")
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
        print("=== 保存開始 ===")
        print("種目名: '\(exerciseName)'")
        print("セット数: \(sets.count)")
        
        // 編集モードの場合、既存のデータを削除
        if isEditMode {
            print("編集モード: 既存データを削除中...")
            for workout in existingWorkouts {
                print("削除するワークアウト: 種目='\(workout.exerciseName ?? "nil")', 重量=\(workout.weight)")
                viewContext.delete(workout)
            }
        }
        
        // 新しいデータを保存
        for (index, set) in sets.enumerated() {
            let newWorkout = WorkoutEntry(context: viewContext)
            newWorkout.date = selectedDate
            newWorkout.exerciseName = exerciseName // ← 重要：必ず種目名を設定
            newWorkout.weight = set.weight
            newWorkout.sets = 1 // 1セットずつ保存
            newWorkout.reps = Int16(set.reps)
            newWorkout.caloriesBurned = Double(calculateTotalCalories()) / Double(sets.count)
            newWorkout.memo = set.memo.isEmpty ? nil : set.memo
            
            print("保存するワークアウト[\(index)]: 種目='\(newWorkout.exerciseName ?? "nil")', 重量=\(newWorkout.weight), 回数=\(newWorkout.reps)")
        }
        
        do {
            try viewContext.save()
            print("保存成功")
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("保存エラー: \(error)")
        }
        print("=== 保存終了 ===")
    }
    
    private func deleteWorkoutEntries() {
        // この日のこの種目の記録を削除
        for workout in existingWorkouts {
            viewContext.delete(workout)
        }
        
        do {
            try viewContext.save()
            print("記録を削除しました: \(exerciseName)")
        } catch {
            print("削除エラー: \(error)")
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - ExerciseSet データ構造
struct ExerciseSet {
    var weight: Double = 0
    var reps: Int = 0
    var memo: String = ""
}

// MARK: - 日付フォーマッター
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()
