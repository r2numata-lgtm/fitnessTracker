//
//  FoodSearchView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/FoodSearchView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 食材検索画面
struct FoodSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let selectedDate: Date
    
    @State private var searchText = ""
    @State private var searchResults: [FoodSearchResult] = []
    @State private var isSearching = false
    @State private var showingFoodDetail = false
    @State private var selectedFoodResult: FoodSearchResult?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar
                searchResultsSection
            }
            .navigationTitle("食材検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFoodDetail) {
                if let result = selectedFoodResult {
                    FoodDetailInputView(
                        foodResult: result,
                        selectedDate: selectedDate
                    )
                    .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchBar: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("食材名を入力（例：鶏胸肉）", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
    
    private var searchResultsSection: some View {
        Group {
            if searchText.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if isSearching {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("ユーザー投稿データベースを検索中...")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        } else if searchResults.isEmpty {
                            emptySearchResultView
                        } else {
                            ForEach(searchResults, id: \.id) { result in
                                FoodSearchResultRow(result: result) {
                                    selectedFoodResult = result
                                    showingFoodDetail = true
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.5))
            
            Text("食材を検索")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("食材名を入力してユーザー投稿データベースから検索できます")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySearchResultView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("検索結果が見つかりません")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("別のキーワードで検索するか\n手動で栄養情報を入力してください")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("手動で追加") {
                createCustomFood()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Functions
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isSearching = true
        
        Task {
            let results = await IntegratedSearchManager.shared.searchFoodByName(searchText)
            
            await MainActor.run {
                searchResults = results
                isSearching = false
            }
        }
    }
    
    private func createCustomFood() {
        let customFoodResult = FoodSearchResult.local(FoodItem(
            name: searchText,
            nutrition: NutritionInfo.empty,
            category: "カスタム"
        ))
        selectedFoodResult = customFoodResult
        showingFoodDetail = true
    }
}

// MARK: - 統合検索結果行
struct FoodSearchResultRow: View {
    let result: FoodSearchResult
    var showCategory: Bool = true
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text(result.name.prefix(1))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(result.source)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(sourceColor.opacity(0.2))
                            .foregroundColor(sourceColor)
                            .cornerRadius(4)
                        
                        if showCategory, let category = result.category {
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(categoryColor.opacity(0.2))
                                .foregroundColor(categoryColor)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(result.nutrition.calories))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryColor: Color {
        switch result.category {
        case "肉類": return .red
        case "魚介類": return .blue
        case "野菜": return .green
        case "果物": return .orange
        case "穀物": return .brown
        case "乳製品": return .purple
        default: return .gray
        }
    }
    
    private var sourceColor: Color {
        switch result.source {
        case let s where s.contains("基本食材"): return .blue
        case let s where s.contains("投稿データ"): return .green
        default: return .gray
        }
    }
}

// MARK: - 食材詳細入力画面
struct FoodDetailInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let foodResult: FoodSearchResult
    let selectedDate: Date
    
    @State private var selectedMealType: MealType = .lunch
    @State private var servingMultiplier: Double = 1.0
    @State private var isCustomMode = false
    @State private var customCalories: Double = 0
    @State private var customProtein: Double = 0
    @State private var customFat: Double = 0
    @State private var customCarbohydrates: Double = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingVerifyConfirm = false
    @State private var showingReportSheet = false
    
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
    
    var body: some View {
        NavigationView {
            Form {
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
                
                Section("食事の種類") {
                    Picker("食事タイプ", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.displayName).tag(mealType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if !isCustomMode {
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
                    
                    Section("栄養情報（調整後）") {
                        let actualGrams = foodItem.nutrition.servingSize * servingMultiplier
                        let adjustedNutrition = foodItem.nutrition.scaled(to: actualGrams)
                        
                        NutritionDisplayRow(label: "カロリー", value: safeInt(adjustedNutrition.calories), unit: "kcal")
                        NutritionDisplayRow(label: "たんぱく質", value: safeInt(adjustedNutrition.protein), unit: "g")
                        NutritionDisplayRow(label: "脂質", value: safeInt(adjustedNutrition.fat), unit: "g")
                        NutritionDisplayRow(label: "炭水化物", value: safeInt(adjustedNutrition.carbohydrates), unit: "g")
                    }
                } else {
                    Section("栄養情報（手動入力）") {
                        HStack {
                            Text("カロリー")
                            Spacer()
                            TextField("0", value: $customCalories, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("kcal")
                        }
                        
                        HStack {
                            Text("たんぱく質")
                            Spacer()
                            TextField("0", value: $customProtein, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("g")
                        }
                        
                        HStack {
                            Text("脂質")
                            Spacer()
                            TextField("0", value: $customFat, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("g")
                        }
                        
                        HStack {
                            Text("炭水化物")
                            Spacer()
                            TextField("0", value: $customCarbohydrates, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("g")
                        }
                    }
                }
                
                Section {
                    Toggle("手動で栄養情報を入力", isOn: $isCustomMode)
                }
                
                if isSharedProduct {
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
            }
            .navigationTitle("食材詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveFoodItem()
                    }
                }
            }
            .alert("結果", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("成功") || alertMessage.contains("送信") {
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
    
    // MARK: - Helper Functions
    
    private func safeInt(_ value: Double) -> Int {
        if value.isNaN || value.isInfinite {
            return 0
        }
        return Int(value.rounded())
    }
    
    private var sourceColor: Color {
        switch foodResult.source {
        case let s where s.contains("基本食材"): return .blue
        case let s where s.contains("投稿データ"): return .green
        default: return .gray
        }
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
            
            if isCustomMode {
                nutritionToSave = NutritionInfo(
                    calories: customCalories,
                    protein: customProtein,
                    fat: customFat,
                    carbohydrates: customCarbohydrates,
                    sugar: customCarbohydrates * 0.8,
                    servingSize: 100
                )
                amountToSave = 100
                
                Task {
                    do {
                        try await IntegratedSearchManager.shared.saveManualEntry(
                            name: foodItem.name,
                            nutrition: nutritionToSave,
                            category: foodItem.category,
                            brand: foodItem.brand
                        )
                        print("✅ 手動入力をユーザーDBに保存完了")
                    } catch {
                        print("⚠️ ユーザーDB保存エラー: \(error)")
                    }
                }
            } else {
                let actualGrams = foodItem.nutrition.servingSize * servingMultiplier
                nutritionToSave = foodItem.nutrition.scaled(to: actualGrams)
                amountToSave = actualGrams
            }
            
            try FoodSaveManager.saveFoodItem(
                context: viewContext,
                foodItem: FoodItem(
                    name: foodItem.name,
                    nutrition: nutritionToSave,
                    category: foodItem.category,
                    brand: foodItem.brand
                ),
                amount: amountToSave,
                mealType: selectedMealType,
                date: selectedDate
            )
            
            alertMessage = "食材情報を保存しました！"
            showingAlert = true
            
        } catch {
            print("保存エラー: \(error)")
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - 栄養情報表示行
struct NutritionDisplayRow: View {
    let label: String
    let value: Int
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)")
                .fontWeight(.semibold)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
}

struct FoodSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchView(selectedDate: Date())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
