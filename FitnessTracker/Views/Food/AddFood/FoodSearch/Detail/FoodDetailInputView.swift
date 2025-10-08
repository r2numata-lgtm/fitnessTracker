//
//  FoodDetailInputView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/Detail/FoodDetailInputView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 食材詳細入力画面
struct FoodDetailInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let foodResult: FoodSearchResult
    let selectedDate: Date
    let onSaved: (() -> Void)?
    
    @State private var selectedMealType: MealType = .lunch
    @State private var servingMultiplier: Double = 1.0
    @State private var isCustomMode: Bool
    @State private var customCalories: Double = 0
    @State private var customProtein: Double = 0
    @State private var customFat: Double = 0
    @State private var customCarbohydrates: Double = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingVerifyConfirm = false
    @State private var showingReportSheet = false
    
    init(foodResult: FoodSearchResult, selectedDate: Date, onSaved: (() -> Void)? = nil) {
        self.foodResult = foodResult
        self.selectedDate = selectedDate
        self.onSaved = onSaved
        
        // 手動追加（カロリーが0）の場合は手動入力モードで開始
        let nutrition: NutritionInfo
        switch foodResult {
        case .local(let food):
            nutrition = food.nutrition
        case .shared(let product):
            nutrition = product.nutrition
        }
        
        _isCustomMode = State(initialValue: nutrition.calories == 0)
        
        print("=== FoodDetailInputView 初期化 ===")
        print("食材: \(foodResult.name)")
        print("カロリー: \(nutrition.calories)")
        print("servingSize: \(nutrition.servingSize)")
        print("手動入力モード: \(nutrition.calories == 0)")
    }
    
    var body: some View {
        NavigationView {
            Form {
                productInfoSection
                
                mealTypeSection
                
                nutritionInputSection
                
                if foodItem.nutrition.servingSize > 0 {
                    toggleSection
                }
                
                if isSharedProduct {
                    qualityManagementSection
                }
            }
            .navigationTitle("食材詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("結果", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("成功") || alertMessage.contains("送信") {
                        onSaved?()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .confirmationDialog("情報の確認", isPresented: $showingVerifyConfirm) {
                Button("この情報が正しいことを確認") {
                    verifyProduct()
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("この食材情報が正確であることを確認しますか？")
            }
            .sheet(isPresented: $showingReportSheet) {
                if let product = sharedProduct {
                    ReportFoodView(productId: product.id)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var productInfoSection: some View {
        Section("商品情報") {
            VStack(alignment: .leading, spacing: 8) {
                Text(foodItem.name)
                    .font(.headline)
                
                if let brand = foodItem.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(foodResult.source)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(sourceColor.opacity(0.1))
                    .foregroundColor(sourceColor)
                    .cornerRadius(4)
            }
        }
    }
    
    private var mealTypeSection: some View {
        Section("食事の種類") {
            Picker("食事タイプ", selection: $selectedMealType) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Text(mealType.displayName).tag(mealType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    @ViewBuilder
    private var nutritionInputSection: some View {
        if !isCustomMode && foodItem.nutrition.servingSize > 0 {
            servingSizeSection
            adjustedNutritionSection
        } else {
            manualInputSection
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
                
                Text("(\(Int(foodItem.nutrition.servingSize * servingMultiplier))g相当)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var adjustedNutritionSection: some View {
        Section("栄養情報（調整後）") {
            let actualGrams = foodItem.nutrition.servingSize * servingMultiplier
            let adjustedNutrition = foodItem.nutrition.scaled(to: actualGrams)
            
            NutritionDisplayRow(label: "カロリー", value: safeInt(adjustedNutrition.calories), unit: "kcal")
            NutritionDisplayRow(label: "たんぱく質", value: safeInt(adjustedNutrition.protein), unit: "g")
            NutritionDisplayRow(label: "脂質", value: safeInt(adjustedNutrition.fat), unit: "g")
            NutritionDisplayRow(label: "炭水化物", value: safeInt(adjustedNutrition.carbohydrates), unit: "g")
        }
    }
    
    private var manualInputSection: some View {
        Section("栄養情報（手動入力）") {
            NutritionInputField(label: "カロリー", value: $customCalories, unit: "kcal")
            NutritionInputField(label: "たんぱく質", value: $customProtein, unit: "g")
            NutritionInputField(label: "脂質", value: $customFat, unit: "g")
            NutritionInputField(label: "炭水化物", value: $customCarbohydrates, unit: "g")
        }
    }
    
    private var toggleSection: some View {
        Section {
            Toggle("手動で栄養情報を入力", isOn: $isCustomMode)
        }
    }
    
    private var qualityManagementSection: some View {
        Section("データ品質管理") {
            Button(action: {
                showingVerifyConfirm = true
            }) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("この情報が正しいことを確認")
                        .foregroundColor(.primary)
                }
            }
            
            Button(action: {
                showingReportSheet = true
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("間違いを報告")
                        .foregroundColor(.primary)
                }
            }
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
                saveFoodItem()
            }
            .disabled(isCustomMode && customCalories == 0)
        }
    }
    
    // MARK: - Computed Properties
    
    private var foodItem: FoodItem {
        switch foodResult {
        case .local(let food):
            return food
        case .shared(let product):
            return FoodItem(
                name: product.name,
                nutrition: product.nutrition,
                category: product.category,
                brand: product.brand
            )
        }
    }
    
    private var isSharedProduct: Bool {
        if case .shared = foodResult {
            return true
        }
        return false
    }
    
    private var sharedProduct: SharedProduct? {
        if case .shared(let product) = foodResult {
            return product
        }
        return nil
    }
    
    private var sourceColor: Color {
        switch foodResult.source {
        case let s where s.contains("基本食材"): return .blue
        case let s where s.contains("投稿データ"): return .green
        default: return .gray
        }
    }
    
    // MARK: - Helper Functions
    
    private func safeInt(_ value: Double) -> Int {
        if value.isNaN || value.isInfinite {
            return 0
        }
        return Int(value.rounded())
    }
    
    private func verifyProduct() {
        guard let product = sharedProduct else { return }
        
        Task {
            do {
                try await SharedProductManager.shared.verifyProduct(product.id)
                
                await MainActor.run {
                    alertMessage = "確認ありがとうございます！\nデータの信頼度が向上しました。"
                    showingAlert = true
                }
            } catch SharedProductError.alreadyActioned {
                await MainActor.run {
                    alertMessage = "既にこの食材を確認済みです"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "確認の送信に失敗しました"
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveFoodItem() {
        do {
            let nutritionToSave: NutritionInfo
            let amountToSave: Double
            let foodItemToSave: FoodItem
            let shouldSaveToUserDB: Bool
            
            if isCustomMode || foodItem.nutrition.servingSize == 0 {
                // 手動入力の場合
                nutritionToSave = NutritionInfo(
                    calories: customCalories,
                    protein: customProtein,
                    fat: customFat,
                    carbohydrates: customCarbohydrates,
                    sugar: customCarbohydrates * 0.8,
                    servingSize: 100
                )
                amountToSave = 100
                
                foodItemToSave = FoodItem(
                    name: foodItem.name,
                    nutrition: nutritionToSave,
                    category: foodItem.category,
                    brand: foodItem.brand
                )
                
                // 判定：完全に新規作成の場合のみユーザーDBに保存
                shouldSaveToUserDB = switch foodResult {
                case .local(let food):
                    food.nutrition.calories == 0
                case .shared:
                    false
                }
                
                print("=== 手動入力保存判定 ===")
                print("食材名: \(foodItemToSave.name)")
                print("ユーザーDBに保存: \(shouldSaveToUserDB)")
                
                // ユーザーDBへの保存（条件付き）
                if shouldSaveToUserDB {
                    Task {
                        do {
                            try await IntegratedSearchManager.shared.saveManualEntry(
                                name: foodItemToSave.name,
                                nutrition: nutritionToSave,
                                category: foodItemToSave.category,
                                brand: foodItemToSave.brand
                            )
                            print("✅ 新規食材をユーザーDBに保存: \(foodItemToSave.name)")
                        } catch {
                            print("⚠️ ユーザーDB保存エラー: \(error)")
                        }
                    }
                } else {
                    print("ℹ️ 既存食材の調整のため、ユーザーDBへは保存しない")
                }
            } else {
                // 通常の保存（既存の栄養情報を使用）
                let actualGrams = foodItem.nutrition.servingSize * servingMultiplier
                nutritionToSave = foodItem.nutrition.scaled(to: actualGrams)
                amountToSave = actualGrams
                foodItemToSave = foodItem
            }
            
            // Core Dataに保存（常に実行）
            try FoodSaveManager.saveFoodItem(
                context: viewContext,
                foodItem: foodItemToSave,
                amount: amountToSave,
                mealType: selectedMealType,
                date: selectedDate
            )
            
            // よく使う食材に追加
            FavoriteFoodManager.shared.addFavorite(foodItemToSave)
            
            alertMessage = "食材情報を保存しました！"
            showingAlert = true
            
        } catch {
            print("保存エラー: \(error)")
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Helper Components

struct NutritionInputField: View {
    let label: String
    @Binding var value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            Text(unit)
        }
    }
}

#Preview {
    FoodDetailInputView(
        foodResult: .local(FoodItem(
            name: "鶏胸肉",
            nutrition: NutritionInfo(
                calories: 191,
                protein: 23.3,
                fat: 1.9,
                carbohydrates: 0,
                sugar: 0
            ),
            category: "肉類"
        )),
        selectedDate: Date()
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
