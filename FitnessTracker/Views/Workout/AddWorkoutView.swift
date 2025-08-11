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
    
    // 初期運動種目（後でCore Dataから取得するように変更予定）
    @State private var exercisesByCategory: [String: [String]] = [
        "胸": ["ベンチプレス", "インクラインベンチプレス", "ダンベルフライ", "腕立て伏せ"],
        "背中": ["デッドリフト", "懸垂", "ラットプルダウン", "ベントオーバーロー"],
        "肩": ["ショルダープレス", "サイドレイズ", "リアレイズ", "アップライトロー"],
        "腕": ["バーベルカール", "トライセプスエクステンション", "ハンマーカール", "ディップス"],
        "脚": ["スクワット", "レッグプレス", "レッグカール", "カーフレイズ"],
        "腹筋": ["クランチ", "プランク", "レッグレイズ", "バイシクルクランチ"],
        "有酸素": ["ランニング", "サイクリング", "ウォーキング", "エリプティカル"]
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // カテゴリ選択
                Picker("カテゴリ", selection: $selectedExerciseCategory) {
                    ForEach(exerciseCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 種目一覧
                List {
                    ForEach(exercisesByCategory[selectedExerciseCategory] ?? [], id: \.self) { exercise in
                        Button(action: {
                            selectedExercise = exercise
                            showingExerciseDetail = true
                        }) {
                            HStack {
                                Text(exercise)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // 種目追加ボタン
                    Button(action: {
                        showingAddExercise = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("新しい種目を追加")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("種目選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView(
                    category: selectedExerciseCategory,
                    onExerciseAdded: { newExercise in
                        addExerciseToCategory(newExercise, to: selectedExerciseCategory)
                    }
                )
            }
            .sheet(isPresented: $showingExerciseDetail) {
                ExerciseDetailView(
                    exerciseName: selectedExercise,
                    selectedDate: selectedDate,
                    isEditMode: false
                )
                .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private func addExerciseToCategory(_ exercise: String, to category: String) {
        if exercisesByCategory[category] != nil {
            exercisesByCategory[category]?.append(exercise)
        } else {
            exercisesByCategory[category] = [exercise]
        }
    }
}
