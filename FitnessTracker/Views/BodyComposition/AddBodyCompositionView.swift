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
    
    // 入力値
    @State private var height: Double = 170
    @State private var weight: Double = 70
    @State private var age: Int = 30
    @State private var gender: Gender = .male
    @State private var bodyFatPercentage: Double = 0
    @State private var muscleMass: Double = 0
    @State private var activityLevel: ActivityLevel = .light
    
    // アラート
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 最新データを取得してデフォルト値に使用
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)],
        animation: .default
    )
    private var previousEntries: FetchedResults<BodyComposition>
    
    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                detailSection
                calculationResultSection
            }
            .navigationTitle("体組成記録")
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("活動レベル")
                    .font(.subheadline)
                
                Picker("活動レベル", selection: $activityLevel) {
                    ForEach(ActivityLevel.allCases) { level in
                        VStack(alignment: .leading) {
                            Text(level.rawValue)
                            Text(level.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(level)
                    }
                }
                .pickerStyle(MenuPickerStyle())
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
            
            HStack {
                Text("推定消費カロリー")
                Spacer()
                Text("\(Int(calculateTDEE()))kcal/日")
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
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
    
    private func calculateTDEE() -> Double {
        BodyCompositionCalculator.calculateTDEE(
            bmr: calculateBMR(),
            activityLevel: activityLevel
        )
    }
    
    private func calculateLeanBodyMass() -> Double {
        BodyCompositionCalculator.calculateLeanBodyMass(
            weight: weight,
            bodyFatPercentage: bodyFatPercentage
        )
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
        
        // 保存
        let newEntry = BodyComposition(context: viewContext)
        newEntry.id = UUID()
        newEntry.date = Date()
        newEntry.height = height
        newEntry.weight = weight
        newEntry.age = Int16(age)
        newEntry.gender = gender.storageValue
        newEntry.bodyFatPercentage = bodyFatPercentage
        newEntry.muscleMass = muscleMass
        newEntry.basalMetabolicRate = calculateBMR()
        newEntry.activityLevel = activityLevel.storageValue
        
        do {
            try viewContext.save()
            print("✅ 体組成データを保存しました")
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("❌ 保存エラー: \(error)")
            alertMessage = "保存に失敗しました"
            showingAlert = true
        }
    }
}

#Preview {
    AddBodyCompositionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
