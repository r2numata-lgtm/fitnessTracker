//
//  FoodHistoryDetailView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/Detail/FoodHistoryDetailView.swift
//

import SwiftUI
import CoreData

// MARK: - 履歴詳細・再保存画面
struct FoodHistoryDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let foodEntry: FoodEntry
    let selectedDate: Date
    
    @State private var selectedMealType: MealType
    @State private var servingMultiplier: Double = 1.0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(foodEntry: FoodEntry, selectedDate: Date) {
        self.foodEntry = foodEntry
        self.selectedDate = selectedDate
        
        // 食事タイプを初期化
        if let mealType = foodEntry.mealType,
           let type = MealType.allCases.first(where: { $0.rawValue == mealType }) {
            _selectedMealType = State(initialValue: type)
        } else {
            _selectedMealType = State(initialValue: .lunch)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                originalInfoSection
                mealTypeSection
                servingSizeSection
                adjustedNutritionSection
            }
            .navigationTitle("分量を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("結果", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("成功") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Sections
    
    // originalInfoSection を更新
    private var originalInfoSection: some View {
        Section("履歴の食材") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(foodEntry.foodName ?? "不明な食材")
                        .font(.headline)
                    
                    Spacer()
                    
                    if let photoData = foodEntry.photo,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                // ベースの栄養情報を表示
                VStack(alignment: .leading, spacing: 4) {
                    Text("基準（1人前 = 100g）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("カロリー")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(baseNutrition.calories))kcal")
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("たんぱく質")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(baseNutrition.protein, specifier: "%.1f")g")
                    }
                }
                .font(.caption)
                .padding(.top, 4)
            }
        }
    }

    // ベースの栄養情報を計算
    private var baseNutrition: NutritionInfo {
        let baseServingSize = 100.0
        let ratio = baseServingSize / foodEntry.servingSize
        
        return NutritionInfo(
            calories: foodEntry.calories * ratio,
            protein: foodEntry.protein * ratio,
            fat: foodEntry.fat * ratio,
            carbohydrates: foodEntry.carbohydrates * ratio,
            sugar: foodEntry.sugar * ratio,
            servingSize: baseServingSize,
            fiber: foodEntry.fiber > 0 ? foodEntry.fiber * ratio : nil,
            sodium: foodEntry.sodium > 0 ? foodEntry.sodium * ratio : nil
        )
    }
    
    private var mealTypeSection: some View {
        Section("食事タイプ") {
            Picker("食事タイプ", selection: $selectedMealType) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Text(mealType.displayName).tag(mealType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var servingSizeSection: some View {
        Section("分量") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("分量")
                    Spacer()
                    Text(String(format: "%.1f", servingMultiplier))
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("人前")
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $servingMultiplier,
                    in: 0.1...5.0,
                    step: 0.1
                ) {
                    Text("分量")
                }
                .accentColor(.purple)
                
                HStack {
                    Text("0.1人前")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("5.0人前")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var adjustedNutritionSection: some View {
        Section("この分量での栄養情報") {
            let adjustedNutrition = foodEntry.nutritionInfo.scaled(to: foodEntry.servingSize * servingMultiplier)
            
            NutritionDisplayRow(label: "カロリー", value: Int(adjustedNutrition.calories), unit: "kcal")
            NutritionDisplayRow(label: "たんぱく質", value: Int(adjustedNutrition.protein), unit: "g")
            NutritionDisplayRow(label: "脂質", value: Int(adjustedNutrition.fat), unit: "g")
            NutritionDisplayRow(label: "炭水化物", value: Int(adjustedNutrition.carbohydrates), unit: "g")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("保存") {
                saveFromHistory()
            }
        }
    }
    
    // MARK: - Functions
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E) HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func saveFromHistory() {
        do {
            // ベースの栄養情報から計算
            let baseServing = 100.0
            let ratio = baseServing / foodEntry.servingSize
            
            // ベースの栄養情報を作成
            let baseNutrition = NutritionInfo(
                calories: foodEntry.calories * ratio,
                protein: foodEntry.protein * ratio,
                fat: foodEntry.fat * ratio,
                carbohydrates: foodEntry.carbohydrates * ratio,
                sugar: foodEntry.sugar * ratio,
                servingSize: baseServing
            )
            
            // ユーザーが選択した人前分を計算
            let adjustedAmount = baseServing * servingMultiplier
            let adjustedNutrition = baseNutrition.scaled(to: adjustedAmount)
            
            // 保存
            try FoodSaveManager.saveFoodEntry(
                context: viewContext,
                name: foodEntry.foodName ?? "不明な食材",
                nutrition: adjustedNutrition,
                mealType: selectedMealType,
                date: selectedDate,
                photo: foodEntry.photo
            )
            
            alertMessage = "食材を保存しました！"
            showingAlert = true
            
        } catch {
            print("保存エラー: \(error)")
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showingAlert = true
        }
    }}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleEntry = FoodEntry(context: context)
    sampleEntry.foodName = "鶏胸肉"
    sampleEntry.calories = 191
    sampleEntry.protein = 23.3
    sampleEntry.fat = 1.9
    sampleEntry.carbohydrates = 0
    sampleEntry.sugar = 0
    sampleEntry.servingSize = 100
    sampleEntry.mealType = "昼食"
    sampleEntry.date = Date()
    
    return FoodHistoryDetailView(
        foodEntry: sampleEntry,
        selectedDate: Date()
    )
    .environment(\.managedObjectContext, context)
}
