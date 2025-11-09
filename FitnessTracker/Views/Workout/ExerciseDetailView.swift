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
    
    init(exerciseName: String, selectedDate: Date, isEditMode: Bool = false, sessionId: UUID? = nil) {
        self.exerciseName = exerciseName
        self.selectedDate = selectedDate
        self.isEditMode = isEditMode
        
        print("=== ExerciseDetailView初期化 ===")
        print("受け取った種目名: '\(exerciseName)'")
        print("種目名の長さ: \(exerciseName.count)")
        print("種目名が空?: \(exerciseName.isEmpty)")
        print("編集モード: \(isEditMode)")
        print("選択日: \(selectedDate)")
        
        // 編集モードの場合、その日のその種目の記録を取得（日時順でソート）
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("検索範囲: \(startOfDay) 〜 \(endOfDay)")
        print("検索クエリ: exerciseName == '\(exerciseName)'")
        
        if isEditMode, let sessionId = sessionId {
            // セッションIDで記録を取得
            self._existingWorkouts = FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: true)],
                predicate: NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
            )
        } else {
            // 新規モードの場合は空のFetchRequest
            self._existingWorkouts = FetchRequest(
                sortDescriptors: [],
                predicate: NSPredicate(value: false)
            )
        }
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
    
    // MARK: - Private Methods
    
    // 既存データの読み込み処理を改善（順番を保持）
    private func loadExistingDataIfNeeded() {
        print("=== データ読み込み開始 ===")
        print("種目名: '\(exerciseName)'")
        print("編集モード: \(isEditMode)")
        
        if isEditMode {
            // 編集モード: 既存の記録を読み込む
            print("既存ワークアウト数: \(existingWorkouts.count)")
            
            if !existingWorkouts.isEmpty {
                var loadedSets: [ExerciseSet] = []
                
                for (index, workout) in existingWorkouts.enumerated() {
                    let set = ExerciseSet(
                        weight: workout.weight,
                        reps: Int(workout.reps),
                        memo: workout.memo ?? ""
                    )
                    loadedSets.append(set)
                    print("読み込みセット[\(index)]: 重量=\(set.weight)kg, 回数=\(set.reps)回")
                }
                
                sets = loadedSets
                print("総セット数: \(sets.count)")
            } else {
                print("既存データなし")
                sets = [ExerciseSet()]
            }
        } else {
            // 新規追加モード: 前回記録をデフォルト値として設定
            print("新規追加モード: 前回記録を検索中...")
            loadPreviousRecordAsDefault()
        }
        
        print("=== データ読み込み完了 ===")
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
    
    // 保存処理を修正（セットの順番を保持）
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
        
        // 基準日時を設定
        let calendar = Calendar.current
        let baseDate: Date
        if isEditMode {
            // 編集モードの場合は、その日の0時から
            baseDate = calendar.startOfDay(for: selectedDate)
        } else {
            // 新規追加の場合は、現在時刻から
            baseDate = Date()
        }
        
        // セッションIDを生成（このセッション全体で共通）
        let sessionId = UUID()
        print("セッションID: \(sessionId)")

        // 新しいデータを保存（セットごとに1秒ずつずらして順番を保持）
        for (index, set) in sets.enumerated() {
            // セットの順番を保持するため、1秒ずつずらして保存
            let setDate = calendar.date(byAdding: .second, value: index, to: baseDate) ?? baseDate
            
            let newWorkout = WorkoutEntry(context: viewContext)
            newWorkout.date = setDate
            newWorkout.exerciseName = exerciseName
            newWorkout.weight = set.weight
            newWorkout.sets = 1
            newWorkout.reps = Int16(set.reps)
            newWorkout.caloriesBurned = Double(calculateTotalCalories()) / Double(sets.count)
            newWorkout.memo = set.memo.isEmpty ? nil : set.memo
            newWorkout.sessionId = sessionId  // ← セッションIDを設定
            
            print("保存するワークアウト[\(index)]: 種目='\(newWorkout.exerciseName ?? "nil")', 重量=\(newWorkout.weight), 回数=\(newWorkout.reps), sessionId=\(sessionId)")
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
    
    // 前回記録をデフォルト値として設定
    private func loadPreviousRecordAsDefault() {
        let fetchRequest: NSFetchRequest<WorkoutEntry> = WorkoutEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseName == %@", exerciseName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            // 最新の1件を取得してsessionIdを確認
            let latestRecords = try viewContext.fetch(fetchRequest)
            
            if let latestRecord = latestRecords.first, let sessionId = latestRecord.sessionId {
                print("✅ 前回記録のセッションID: \(sessionId)")
                
                // 同じセッションIDの全記録を取得
                let sessionFetchRequest: NSFetchRequest<WorkoutEntry> = WorkoutEntry.fetchRequest()
                sessionFetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
                sessionFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: true)]
                
                let sessionRecords = try viewContext.fetch(sessionFetchRequest)
                print("前回セッションのセット数: \(sessionRecords.count)")
                
                // 全セットをデフォルト値として設定
                sets = sessionRecords.map { workout in
                    ExerciseSet(
                        weight: workout.weight,
                        reps: Int(workout.reps),
                        memo: workout.memo ?? ""
                    )
                }
                
                print("✅ 前回記録を全セット読み込み: \(sets.count)セット")
            } else {
                print("⚠️ 前回記録なし - 空のセットで開始")
                sets = [ExerciseSet()]
            }
        } catch {
            print("❌ 前回記録取得エラー: \(error)")
            sets = [ExerciseSet()]
        }
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
