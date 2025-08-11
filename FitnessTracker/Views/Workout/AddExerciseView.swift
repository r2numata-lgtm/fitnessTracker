//
//  AddExerciseView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/02.
//

import SwiftUI

// MARK: - 運動種目追加画面
struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let category: String
    let onExerciseAdded: (String) -> Void
    
    @State private var exerciseName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("\(category)の新しい種目を追加")) {
                    TextField("運動種目名を入力", text: $exerciseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("例: \(getExampleExercise())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Text("・運動種目名は分かりやすい名前にしてください")
                    Text("・既存の種目と重複しないようにしてください")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .navigationTitle("種目追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addExercise()
                    }
                    .disabled(exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("エラー", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func getExampleExercise() -> String {
        let examples: [String: String] = [
            "胸": "インクラインダンベルプレス",
            "背中": "ワンハンドロー",
            "肩": "フロントレイズ",
            "腕": "プリーチャーカール",
            "脚": "ブルガリアンスクワット",
            "腹筋": "ロシアンツイスト",
            "有酸素": "エアロバイク"
        ]
        return examples[category] ?? "新しい運動"
    }
    
    private func addExercise() {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // バリデーション
        if trimmedName.isEmpty {
            alertMessage = "運動種目名を入力してください"
            showingAlert = true
            return
        }
        
        if trimmedName.count > 30 {
            alertMessage = "運動種目名は30文字以内で入力してください"
            showingAlert = true
            return
        }
        
        // 特殊文字チェック（基本的な日本語、英数字、スペースのみ許可）
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゃゅょっァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモヤユヨラリルレロワヲンヴー・（）()【】[]、。・")
        
        if trimmedName.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            alertMessage = "使用できない文字が含まれています"
            showingAlert = true
            return
        }
        
        // 成功時の処理
        onExerciseAdded(trimmedName)
        presentationMode.wrappedValue.dismiss()
    }
}
