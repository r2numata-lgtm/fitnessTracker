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
    @State private var hasLoadedData = false
    
    // 編集モード用
    @FetchRequest private var existingWorkouts: FetchedResults<WorkoutEntry>
    
    init(exerciseName: String, selectedDate: Date, isEditMode: Bool = false) {
        self.exerciseName = exerciseName
        self.selectedDate = selectedDate
        self.isEditMode = isEditMode
        
        print("=== ExerciseDetailView初期化 ===")
        print("受け取った種目名: '\(exerciseName)'")
        print("種目名の長さ: \(exerciseName.count)")
        print("種目名が空?: \(exerciseName.isEmpty)")
        print("編集モード: \(isEditMode)")
        print("選択日: \(selectedDate)")
        
        // 編集モードの場合、その日のその種目の記録を取得
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("検索範囲: \(startOfDay) 〜 \(endOfDay)")
        print("検索クエリ: exerciseName == '\(exerciseName)'")
        
        self._existingWorkouts = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: true)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "exerciseName == %@", exerciseName),
                NSPredicate(format: "date >= %@", startOfDay as NSDate),
                NSPredicate(format: "date < %@", endOfDay as NSDate)
            ])
        )
        print("================================")
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("種目名: '\(exerciseName)'")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("種目名が空?: \(exerciseName.isEmpty ? "Yes" : "No")")
                            .font(.caption)
                            .foregroundColor(exerciseName.isEmpty ? .red : .blue)
                        Text("種目名の長さ: \(exerciseName.count)")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("日付: \(selectedDate, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("既存記録数: \(existingWorkouts.count)")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("読み込み済みセット数: \(sets.count)")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("データ読み込み完了: \(hasLoadedData ? "Yes" : "No")")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("編集モード: \(isEditMode ? "Yes" : "No")")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                // 既存データの詳細表示
                if !existingWorkouts.isEmpty {
                    Section(header: Text("既存データ詳細")) {
                        ForEach(Array(existingWorkouts.enumerated()), id: \.offset) { index, workout in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Record \(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Text("種目: '\(workout.exerciseName ?? "nil")'")
                                    .font(.caption)
                                Text("重量: \(workout.weight)kg")
                                    .font(.caption)
                                Text("回数: \(workout.reps)回")
                                    .font(.caption)
                                Text("日時: \(workout.date)")
                                    .font(.caption)
                            }
                            .foregroundColor(.purple)
                        }
                    }
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
            .navigationTitle(exerciseName.isEmpty ? "種目名なし" : exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                print("=== ExerciseDetailView onAppear ===")
                print("hasLoadedData: \(hasLoadedData)")
                print("existingWorkouts.count: \(existingWorkouts.count)")
                print("sets.count: \(sets.count)")
                
                // 初回表示時のみデータを読み込む
                if !hasLoadedData {
                    loadExistingDataIfNeeded()
                    hasLoadedData = true
                }
                print("==================================")
            }
            .onChange(of: existingWorkouts.count) { newCount in
                print("=== existingWorkouts.count変更 ===")
                print("新しいカウント: \(newCount)")
                print("hasLoadedData: \(hasLoadedData)")
                
                // existingWorkoutsが変更されたときにデータを再読み込み
                if isEditMode && !hasLoadedData && newCount > 0 {
                    loadExistingDataIfNeeded()
                    hasLoadedData = true
                }
                print("================================")
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
    
    // 既存データの読み込み処理を改善
    private func loadExistingDataIfNeeded() {
        guard isEditMode else {
            print("編集モードではないため、データ読み込みをスキップ")
            return
        }
        
        print("=== 既存データ読み込み開始 ===")
        print("種目名: '\(exerciseName)'")
        print("既存ワークアウト数: \(existingWorkouts.count)")
        
        if !existingWorkouts.isEmpty {
            // 既存のセットデータを読み込み
            var loadedSets: [ExerciseSet] = []
            
            for (index, workout) in existingWorkouts.enumerated() {
                let set = ExerciseSet(
                    weight: workout.weight,
                    reps: Int(workout.reps),
                    memo: workout.memo ?? ""
                )
                loadedSets.append(set)
                print("読み込みセット[\(index)]: 重量=\(set.weight)kg, 回数=\(set.reps)回, メモ='\(set.memo)'")
            }
            
            sets = loadedSets
            print("総セット数: \(sets.count)")
        } else {
            print("既存データなし - 新規セットで開始")
            sets = [ExerciseSet()]
        }
        print("=== 既存データ読み込み完了 ===")
    }
    
    private func calculateTotalCalories() -> Int {
        // MET値による消費カロリー計算
        let metValues: [String: Double] = [
            "ベンチプレス": 6.0,
            "インクラインベンチプレス": 6.5,
            "スクワット": 5.0,
            "デッドリフト": 6.0,
            "懸垂": 8.0,
            "腕立て伏せ": 3.8,
            "ショルダープレス": 4.0,
            "ラットプルダウン": 4.5,
            "ランニング": 8.0,
            "ウォーキング": 3.5,
            "サイクリング": 7.0,
            "水泳": 8.0,
            "あああ": 5.0  // テスト用
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
        
        guard !exerciseName.isEmpty else {
            print("❌ エラー: 種目名が空です")
            return
        }
        
        // 編集モードの場合、既存のデータを削除
        if isEditMode {
            print("編集モード: 既存データを削除中...")
            for (index, workout) in existingWorkouts.enumerated() {
                print("削除するワークアウト[\(index)]: 種目='\(workout.exerciseName ?? "nil")', 重量=\(workout.weight)")
                viewContext.delete(workout)
            }
        }
        
        // 新しいデータを保存
        for (index, set) in sets.enumerated() {
            let newWorkout = WorkoutEntry(context: viewContext)
            newWorkout.date = selectedDate
            newWorkout.exerciseName = exerciseName
            newWorkout.weight = set.weight
            newWorkout.sets = 1 // 1セットずつ保存
            newWorkout.reps = Int16(set.reps)
            newWorkout.caloriesBurned = Double(calculateTotalCalories()) / Double(sets.count)
            newWorkout.memo = set.memo.isEmpty ? nil : set.memo
            
            print("保存するワークアウト[\(index)]: 種目='\(newWorkout.exerciseName ?? "nil")', 重量=\(newWorkout.weight), 回数=\(newWorkout.reps)")
        }
        
        do {
            try viewContext.save()
            print("✅ 保存成功")
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("❌ 保存エラー: \(error)")
        }
        print("=== 保存終了 ===")
    }
    
    private func deleteWorkoutEntries() {
        print("=== 記録削除開始 ===")
        print("削除対象の種目: '\(exerciseName)'")
        print("削除対象の記録数: \(existingWorkouts.count)")
        
        // この日のこの種目の記録を削除
        for (index, workout) in existingWorkouts.enumerated() {
            print("削除[\(index)]: 種目='\(workout.exerciseName ?? "nil")', 重量=\(workout.weight)")
            viewContext.delete(workout)
        }
        
        do {
            try viewContext.save()
            print("✅ 記録を削除しました: \(exerciseName)")
        } catch {
            print("❌ 削除エラー: \(error)")
        }
        
        print("=== 記録削除完了 ===")
        presentationMode.wrappedValue.dismiss()
    }
}



// MARK: - 日付フォーマッター
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()
