//
//  AddBodyCompositionView.swift
//  FitnessTracker
//  Views/BodyComposition/AddBodyCompositionView.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import SwiftUI
import CoreData

struct AddBodyCompositionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let selectedDate: Date
    
    // 入力値
    @State private var height: Double = 170
    @State private var weight: Double = 70
    @State private var age: Int = 30
    @State private var gender: Gender = .male
    @State private var bodyFatPercentage: Double = 0
    @State private var muscleMass: Double = 0
    
    // アラート
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 最新データを取得してデフォルト値に使用
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)],
        animation: .default
    )
    private var previousEntries: FetchedResults<BodyComposition>
    
    // 選択日の既存データ
    @State private var existingEntry: BodyComposition?
    
    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                detailSection
                calculationResultSection
            }
            .navigationTitle(formatDate(selectedDate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveBodyComposition()
                    }
                }
            }
            .alert("入力エラー", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                checkExistingEntry()
                loadPreviousValues()
            }
        }
    }
    
    // MARK: - 基本情報セクション
    private var basicInfoSection: some View {
        Section("基本情報") {
            HStack {
                Text("身長(cm)")
                Spacer()
                TextField("170", value: $height, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            
            HStack {
                Text("体重(kg)")
                Spacer()
                TextField("70", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            
            HStack {
                Text("年齢")
                Spacer()
                TextField("30", value: $age, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            
            Picker("性別", selection: $gender) {
                ForEach(Gender.allCases) { gender in
                    Text(gender.rawValue).tag(gender)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - 詳細情報セクション
    private var detailSection: some View {
        Section("詳細情報（オプション）") {
            HStack {
                Text("体脂肪率(%)")
                Spacer()
                TextField("0", value: $bodyFatPercentage, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            
            HStack {
                Text("筋肉量(kg)")
                Spacer()
                TextField("0", value: $muscleMass, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
        }
    }
    
    // MARK: - 計算結果セクション
    private var calculationResultSection: some View {
        Section("計算結果") {
            HStack {
                Text("BMI")
                Spacer()
                VStack(alignment: .trailing) {
                    Text(String(format: "%.1f", calculateBMI()))
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    Text(BodyCompositionCalculator.getBMICategory(calculateBMI()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("基礎代謝量")
                Spacer()
                Text("\(Int(calculateBMR()))kcal/日")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
            
            if bodyFatPercentage > 0 {
                HStack {
                    Text("除脂肪体重")
                    Spacer()
                    Text(String(format: "%.1fkg", calculateLeanBodyMass()))
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    // MARK: - 計算メソッド
    private func calculateBMI() -> Double {
        BodyCompositionCalculator.calculateBMI(weight: weight, height: height)
    }
    
    private func calculateBMR() -> Double {
        if bodyFatPercentage > 0 {
            return BodyCompositionCalculator.calculateBMRWithBodyFat(
                weight: weight,
                bodyFatPercentage: bodyFatPercentage
            )
        } else {
            return BodyCompositionCalculator.calculateBMR(
                weight: weight,
                height: height,
                age: age,
                gender: gender
            )
        }
    }
    
    private func calculateLeanBodyMass() -> Double {
        BodyCompositionCalculator.calculateLeanBodyMass(
            weight: weight,
            bodyFatPercentage: bodyFatPercentage
        )
    }
    
    // MARK: - 既存エントリの確認
    private func checkExistingEntry() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        existingEntry = previousEntries.first { entry in
            entry.date >= startOfDay && entry.date < endOfDay
        }
        
        if let existing = existingEntry {
            // 既存データがあれば、その値を初期値に
            height = existing.height
            weight = existing.weight
            age = Int(existing.age)
            gender = Gender.from(storageValue: existing.gender)
            bodyFatPercentage = existing.bodyFatPercentage
            muscleMass = existing.muscleMass
            print("✅ \(formatDate(selectedDate))の既存データを読み込みました")
        }
    }
    
    // MARK: - 前回値の読み込み
    private func loadPreviousValues() {
        // 既存データがある場合はスキップ
        if existingEntry != nil { return }
        
        guard let latest = previousEntries.first else { return }
        
        // 身長・年齢・性別は前回値を引き継ぐ
        height = latest.height
        age = Int(latest.age)
        gender = Gender.from(storageValue: latest.gender)
        
        // 体重・体脂肪率・筋肉量はリセット（毎回測定）
        weight = 0
        bodyFatPercentage = 0
        muscleMass = 0
        
        print("✅ 前回の入力値（身長・年齢・性別）を読み込みました")
    }
    
    // MARK: - 保存処理
    private func saveBodyComposition() {
        // バリデーション
        if !BodyCompositionCalculator.isValidHeight(height) {
            alertMessage = "身長は100〜250cmの範囲で入力してください"
            showingAlert = true
            return
        }
        
        if !BodyCompositionCalculator.isValidWeight(weight) {
            alertMessage = "体重は20〜300kgの範囲で入力してください"
            showingAlert = true
            return
        }
        
        if weight == 0 {
            alertMessage = "体重を入力してください"
            showingAlert = true
            return
        }
        
        if !BodyCompositionCalculator.isValidAge(age) {
            alertMessage = "年齢は10〜120歳の範囲で入力してください"
            showingAlert = true
            return
        }
        
        if bodyFatPercentage > 0 && !BodyCompositionCalculator.isValidBodyFatPercentage(bodyFatPercentage) {
            alertMessage = "体脂肪率は3〜60%の範囲で入力してください"
            showingAlert = true
            return
        }
        
        let calendar = Calendar.current
        let saveDate = calendar.startOfDay(for: selectedDate)
        
        // 既存データがあれば更新、なければ新規作成
        let entry: BodyComposition
        if let existing = existingEntry {
            entry = existing
            print("📝 既存データを更新します")
        } else {
            entry = BodyComposition(context: viewContext)
            entry.id = UUID()
            entry.date = saveDate
            print("✨ 新規データを作成します")
        }
        
        // データ設定
        entry.height = height
        entry.weight = weight
        entry.age = Int16(age)
        entry.gender = gender.storageValue
        entry.bodyFatPercentage = bodyFatPercentage
        entry.muscleMass = muscleMass
        entry.basalMetabolicRate = calculateBMR()
        entry.activityLevel = nil  // 活動レベルは使用しない
        
        do {
            try viewContext.save()
            print("✅ 体組成データを保存しました: \(formatDate(selectedDate))")
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("❌ 保存エラー: \(error)")
            alertMessage = "保存に失敗しました"
            showingAlert = true
        }
    }
    
    // MARK: - 日付フォーマット
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今日の体組成"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年M月d日の体組成"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: date)
        }
    }
}

#Preview {
    AddBodyCompositionView(selectedDate: Date())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
