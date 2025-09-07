//
//  AddWorkoutView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI
import CoreData

// MARK: - 筋トレ追加画面（種目選択）
//
//  AddWorkoutView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI
import CoreData

// MARK: - 筋トレ追加画面（種目選択）
struct AddWorkoutView: View {
   @Environment(\.managedObjectContext) private var viewContext
   @Environment(\.presentationMode) var presentationMode
   
   let selectedDate: Date
   
   @State private var selectedExerciseCategory = "胸"
   @State private var showingAddExercise = false
   @State private var showingExerciseDetail = false
   @State private var selectedExercise = ""
   
   let exerciseCategories = ["胸", "背中", "肩", "腕", "脚", "腹筋", "有酸素"]
   
   // Core Dataから種目を取得
   @FetchRequest(
       sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
       animation: .default
   )
   private var exercises: FetchedResults<Exercise>
   
   var body: some View {
       NavigationView {
           mainContent
       }
       .onAppear {
           print("AddWorkoutView表示 - 種目数: \(exercises.count)")
           initializeDefaultExercises()
       }
   }
   
   // メインコンテンツを分離
   private var mainContent: some View {
       VStack {
           categoryPicker
           debugInfo
           exerciseList
       }
       .navigationTitle("種目選択")
       .navigationBarTitleDisplayMode(.inline)
       .toolbar {
           toolbarContent
       }
       .sheet(isPresented: $showingAddExercise) {
           addExerciseSheet
       }
       .sheet(isPresented: $showingExerciseDetail) {
           exerciseDetailSheet
       }
   }
   
   // カテゴリピッカーを分離
   private var categoryPicker: some View {
       Picker("カテゴリ", selection: $selectedExerciseCategory) {
           ForEach(exerciseCategories, id: \.self) { category in
               Text(category).tag(category)
           }
       }
       .pickerStyle(SegmentedPickerStyle())
       .padding()
   }
   
   // デバッグ情報を分離
   private var debugInfo: some View {
       VStack {
           Text("総種目数: \(exercises.count)")
               .font(.caption)
               .foregroundColor(.red)
           
           Text("選択カテゴリの種目数: \(filteredExercises.count)")
               .font(.caption)
               .foregroundColor(.red)
           
           Text("選択された種目: '\(selectedExercise)'")
               .font(.caption)
               .foregroundColor(.blue)
       }
       .padding(.horizontal)
   }
   
   // 種目リストを分離
   private var exerciseList: some View {
       List {
           ForEach(filteredExercises, id: \.self) { exercise in
               ExerciseRowView(
                   exercise: exercise,
                   onTap: {
                       selectedExercise = exercise.name ?? ""
                       print("種目選択: '\(exercise.name ?? "")' → selectedExercise: '\(selectedExercise)'")
                       showingExerciseDetail = true
                   }
               )
           }
           .onDelete(perform: deleteExercise)
           
           AddNewExerciseButton {
               showingAddExercise = true
           }
       }
   }
   
   // ツールバーコンテンツを分離
   private var toolbarContent: some ToolbarContent {
       ToolbarItem(placement: .navigationBarLeading) {
           Button("キャンセル") {
               presentationMode.wrappedValue.dismiss()
           }
       }
   }
   
   // シートビューを分離
   private var addExerciseSheet: some View {
       AddExerciseView(
           category: selectedExerciseCategory,
           onExerciseAdded: { newExercise in
               saveNewExercise(name: newExercise, category: selectedExerciseCategory)
           }
       )
   }
   
   private var exerciseDetailSheet: some View {
       Group {
           if !selectedExercise.isEmpty {
               ExerciseDetailView(
                   exerciseName: selectedExercise,
                   selectedDate: selectedDate,
                   isEditMode: false
               )
               .environment(\.managedObjectContext, viewContext)
           } else {
               Text("種目が選択されていません")
                   .foregroundColor(.red)
           }
       }
   }
   
   // 選択されたカテゴリの種目を取得
   private var filteredExercises: [Exercise] {
       let filtered = exercises.filter { $0.category == selectedExerciseCategory }
       print("カテゴリ '\(selectedExerciseCategory)' の種目一覧:")
       for exercise in filtered {
           print("  - \(exercise.name ?? "")")
       }
       return filtered
   }
   
   // 新しい種目を保存
   private func saveNewExercise(name: String, category: String) {
       // 既存の種目名をチェック
       let existingExercise = exercises.first { $0.name == name && $0.category == category }
       if existingExercise != nil {
           print("同じ名前の種目が既に存在します: \(name)")
           return
       }
       
       let newExercise = Exercise(context: viewContext)
       newExercise.name = name
       newExercise.category = category
       newExercise.isCustom = true
       newExercise.createdAt = Date()
       
       do {
           try viewContext.save()
           print("新しい種目を保存しました: \(name) (\(category))")
       } catch {
           print("種目保存エラー: \(error)")
       }
   }
   
   // 種目削除（カスタム種目のみ）
   private func deleteExercise(offsets: IndexSet) {
       withAnimation {
           let exercisesToDelete = filteredExercises
           for index in offsets {
               let exercise = exercisesToDelete[index]
               print("削除対象: \(exercise.name ?? "") (カスタム: \(exercise.isCustom))")
               // カスタム種目のみ削除可能
               if exercise.isCustom {
                   viewContext.delete(exercise)
                   print("削除しました: \(exercise.name ?? "")")
               } else {
                   print("デフォルト種目のため削除をスキップ: \(exercise.name ?? "")")
               }
           }
           
           do {
               try viewContext.save()
           } catch {
               print("種目削除エラー: \(error)")
           }
       }
   }
   
   // 初期種目を登録（初回起動時のみ）
   private func initializeDefaultExercises() {
       // デフォルト種目が既に存在するかチェック
       let defaultExerciseCount = exercises.filter { !$0.isCustom }.count
       print("既存のデフォルト種目数: \(defaultExerciseCount)")
       
       if defaultExerciseCount > 0 {
           print("既に初期データが存在するためスキップ")
           return // 既に初期データが存在
       }
       
       print("初期種目データを作成中...")
       
       let defaultExercises: [String: [String]] = [
           "胸": ["ベンチプレス", "インクラインベンチプレス", "ダンベルフライ", "腕立て伏せ"],
           "背中": ["デッドリフト", "懸垂", "ラットプルダウン", "ベントオーバーロー"],
           "肩": ["ショルダープレス", "サイドレイズ", "リアレイズ", "アップライトロー"],
           "腕": ["バーベルカール", "トライセプスエクステンション", "ハンマーカール", "ディップス"],
           "脚": ["スクワット", "レッグプレス", "レッグカール", "カーフレイズ"],
           "腹筋": ["クランチ", "プランク", "レッグレイズ", "バイシクルクランチ"],
           "有酸素": ["ランニング", "サイクリング", "ウォーキング", "エリプティカル"]
       ]
       
       for (category, exerciseNames) in defaultExercises {
           for exerciseName in exerciseNames {
               let exercise = Exercise(context: viewContext)
               exercise.name = exerciseName
               exercise.category = category
               exercise.isCustom = false
               exercise.createdAt = Date()
               print("作成: \(exerciseName) (\(category))")
           }
       }
       
       do {
           try viewContext.save()
           print("初期種目データを保存完了 - 総数: \(exercises.count)")
       } catch {
           print("初期種目データ保存エラー: \(error)")
       }
   }
}

// MARK: - 種目行のコンポーネント
struct ExerciseRowView: View {
   let exercise: Exercise
   let onTap: () -> Void
   
   var body: some View {
       Button(action: onTap) {
           HStack {
               Text(exercise.name ?? "")
                   .foregroundColor(.primary)
               Spacer()
               if exercise.isCustom {
                   Text("カスタム")
                       .font(.caption)
                       .foregroundColor(.blue)
                       .padding(.horizontal, 6)
                       .padding(.vertical, 2)
                       .background(Color.blue.opacity(0.1))
                       .cornerRadius(4)
               }
               Image(systemName: "chevron.right")
                   .foregroundColor(.secondary)
                   .font(.caption)
           }
       }
   }
}

// MARK: - 新規追加ボタンのコンポーネント
struct AddNewExerciseButton: View {
   let action: () -> Void
   
   var body: some View {
       Button(action: action) {
           HStack {
               Image(systemName: "plus.circle.fill")
                   .foregroundColor(.blue)
               Text("新しい種目を追加")
                   .foregroundColor(.blue)
           }
       }
   }
}
