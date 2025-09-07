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
    @State private var searchResults: [FoodItem] = []
    @State private var isSearching = false
    @State private var showingFoodDetail = false
    @State private var selectedFood: FoodItem?
    @State private var showingRecentFoods = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                searchBar
                
                // 検索結果またはよく使う食材
                if searchText.isEmpty {
                    if showingRecentFoods {
                        recentFoodsSection
                    } else {
                        categoryFoodsSection
                    }
                } else {
                    searchResultsSection
                }
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
                if let food = selectedFood {
                    FoodDetailInputView(
                        foodItem: food,
                        selectedDate: selectedDate
                    )
                    .environment(\.managedObjectContext, viewContext)
                }
            }
            .onAppear {
                // 初期データを読み込み
                loadInitialData()
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
            
            // カテゴリ切り替え
            if searchText.isEmpty {
                Picker("表示切り替え", selection: $showingRecentFoods) {
                    Text("よく使う食材").tag(true)
                    Text("カテゴリ別").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
    
    private var searchResultsSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isSearching {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("検索中...")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if searchResults.isEmpty {
                    emptySearchResultView
                } else {
                    ForEach(searchResults, id: \.id) { food in
                        FoodItemRow(food: food) {
                            selectedFood = food
                            showingFoodDetail = true
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var recentFoodsSection: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text("よく使う食材")
                    .font(.headline)
                    .padding(.horizontal)
                
                LazyVStack(spacing: 12) {
                    ForEach(CommonFoodItems.popular, id: \.id) { food in
                        FoodItemRow(food: food) {
                            selectedFood = food
                            showingFoodDetail = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private var categoryFoodsSection: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(FoodCategory.allCases, id: \.self) { category in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(category.displayName)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(CommonFoodItems.foods(for: category).count)品目")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(CommonFoodItems.foods(for: category).prefix(5), id: \.id) { food in
                                FoodItemRow(food: food, showCategory: false) {
                                    selectedFood = food
                                    showingFoodDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
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
    
    private func loadInitialData() {
        // 初期データの読み込み（必要に応じて）
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isSearching = true
        
        // TODO: 実際の食品データベースAPIを呼び出し
        // 現在は仮のローカル検索
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            searchResults = searchInLocalDatabase(query: searchText)
            isSearching = false
        }
    }
    
    private func searchInLocalDatabase(query: String) -> [FoodItem] {
        let allFoods = CommonFoodItems.allFoods
        return allFoods.filter { food in
            food.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    private func createCustomFood() {
        let customFood = FoodItem(
            name: searchText,
            nutrition: NutritionInfo.empty,
            category: "カスタム"
        )
        selectedFood = customFood
        showingFoodDetail = true
    }
}

// MARK: - Helper Views

struct FoodItemRow: View {
    let food: FoodItem
    var showCategory: Bool = true
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 食材アイコン
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text(food.name.prefix(1))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(categoryColor)
                }
                
                // 食材情報
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if showCategory, let category = food.category {
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(categoryColor.opacity(0.2))
                                .foregroundColor(categoryColor)
                                .cornerRadius(4)
                        }
                        
                        Text("100gあたり")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // カロリー情報
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(food.nutrition.calories))")
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
        switch food.category {
        case "肉類": return .red
        case "魚介類": return .blue
        case "野菜": return .green
        case "果物": return .orange
        case "穀物": return .brown
        case "乳製品": return .purple
        default: return .gray
        }
    }
}

// MARK: - Food Categories

enum FoodCategory: String, CaseIterable {
    case meat = "肉類"
    case seafood = "魚介類"
    case vegetables = "野菜"
    case fruits = "果物"
    case grains = "穀物"
    case dairy = "乳製品"
    case others = "その他"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Common Food Items Database

struct CommonFoodItems {
    static let popular: [FoodItem] = [
        FoodItem(
            name: "白米",
            nutrition: NutritionInfo(calories: 356, protein: 6.1, fat: 0.9, carbohydrates: 77.6, sugar: 77.6),
            category: "穀物"
        ),
        FoodItem(
            name: "鶏胸肉（皮なし）",
            nutrition: NutritionInfo(calories: 191, protein: 23.3, fat: 1.9, carbohydrates: 0, sugar: 0),
            category: "肉類"
        ),
        FoodItem(
            name: "卵",
            nutrition: NutritionInfo(calories: 151, protein: 12.3, fat: 10.3, carbohydrates: 0.3, sugar: 0.3),
            category: "その他"
        ),
        FoodItem(
            name: "バナナ",
            nutrition: NutritionInfo(calories: 93, protein: 1.1, fat: 0.2, carbohydrates: 22.5, sugar: 22.5),
            category: "果物"
        ),
        FoodItem(
            name: "ブロッコリー",
            nutrition: NutritionInfo(calories: 33, protein: 4.3, fat: 0.5, carbohydrates: 5.2, sugar: 1.5),
            category: "野菜"
        )
    ]
    
    static let allFoods: [FoodItem] = [
        // 肉類
        FoodItem(name: "鶏胸肉（皮なし）", nutrition: NutritionInfo(calories: 191, protein: 23.3, fat: 1.9, carbohydrates: 0, sugar: 0), category: "肉類"),
        FoodItem(name: "鶏もも肉（皮あり）", nutrition: NutritionInfo(calories: 253, protein: 16.6, fat: 19.1, carbohydrates: 0, sugar: 0), category: "肉類"),
        FoodItem(name: "豚ロース", nutrition: NutritionInfo(calories: 263, protein: 19.3, fat: 19.2, carbohydrates: 0.2, sugar: 0.2), category: "肉類"),
        FoodItem(name: "牛もも肉", nutrition: NutritionInfo(calories: 165, protein: 21.2, fat: 9.6, carbohydrates: 0.5, sugar: 0.5), category: "肉類"),
        
        // 魚介類
        FoodItem(name: "鮭", nutrition: NutritionInfo(calories: 154, protein: 22.3, fat: 4.1, carbohydrates: 0.1, sugar: 0.1), category: "魚介類"),
        FoodItem(name: "まぐろ（赤身）", nutrition: NutritionInfo(calories: 125, protein: 26.4, fat: 1.4, carbohydrates: 0.1, sugar: 0.1), category: "魚介類"),
        FoodItem(name: "エビ", nutrition: NutritionInfo(calories: 97, protein: 18.4, fat: 0.6, carbohydrates: 0.1, sugar: 0.1), category: "魚介類"),
        
        // 野菜
        FoodItem(name: "ブロッコリー", nutrition: NutritionInfo(calories: 33, protein: 4.3, fat: 0.5, carbohydrates: 5.2, sugar: 1.5), category: "野菜"),
        FoodItem(name: "ほうれん草", nutrition: NutritionInfo(calories: 20, protein: 2.2, fat: 0.4, carbohydrates: 3.1, sugar: 0.4), category: "野菜"),
        FoodItem(name: "トマト", nutrition: NutritionInfo(calories: 19, protein: 0.7, fat: 0.1, carbohydrates: 4.7, sugar: 2.6), category: "野菜"),
        FoodItem(name: "キャベツ", nutrition: NutritionInfo(calories: 23, protein: 1.3, fat: 0.2, carbohydrates: 5.2, sugar: 2.8), category: "野菜"),
        
        // 果物
        FoodItem(name: "バナナ", nutrition: NutritionInfo(calories: 93, protein: 1.1, fat: 0.2, carbohydrates: 22.5, sugar: 22.5), category: "果物"),
        FoodItem(name: "りんご", nutrition: NutritionInfo(calories: 54, protein: 0.2, fat: 0.3, carbohydrates: 14.6, sugar: 10.4), category: "果物"),
        FoodItem(name: "オレンジ", nutrition: NutritionInfo(calories: 43, protein: 1.0, fat: 0.2, carbohydrates: 10.5, sugar: 8.5), category: "果物"),
        
        // 穀物
        FoodItem(name: "白米", nutrition: NutritionInfo(calories: 356, protein: 6.1, fat: 0.9, carbohydrates: 77.6, sugar: 77.6), category: "穀物"),
        FoodItem(name: "玄米", nutrition: NutritionInfo(calories: 350, protein: 6.8, fat: 2.7, carbohydrates: 71.8, sugar: 71.8), category: "穀物"),
        FoodItem(name: "食パン", nutrition: NutritionInfo(calories: 264, protein: 9.3, fat: 4.4, carbohydrates: 46.7, sugar: 46.7), category: "穀物"),
        
        // 乳製品
        FoodItem(name: "牛乳", nutrition: NutritionInfo(calories: 67, protein: 3.3, fat: 3.8, carbohydrates: 4.8, sugar: 4.8), category: "乳製品"),
        FoodItem(name: "ヨーグルト（無糖）", nutrition: NutritionInfo(calories: 62, protein: 3.6, fat: 3.0, carbohydrates: 4.9, sugar: 4.9), category: "乳製品"),
        FoodItem(name: "チーズ", nutrition: NutritionInfo(calories: 339, protein: 22.7, fat: 26.0, carbohydrates: 1.4, sugar: 1.4), category: "乳製品"),
        
        // その他
        FoodItem(name: "卵", nutrition: NutritionInfo(calories: 151, protein: 12.3, fat: 10.3, carbohydrates: 0.3, sugar: 0.3), category: "その他"),
        FoodItem(name: "豆腐", nutrition: NutritionInfo(calories: 72, protein: 6.6, fat: 4.2, carbohydrates: 1.6, sugar: 1.6), category: "その他"),
        FoodItem(name: "納豆", nutrition: NutritionInfo(calories: 200, protein: 16.5, fat: 10.0, carbohydrates: 12.1, sugar: 5.4), category: "その他")
    ]
    
    static func foods(for category: FoodCategory) -> [FoodItem] {
        return allFoods.filter { $0.category == category.rawValue }
    }
}

// MARK: - 食材詳細入力画面（詳細実装）
struct FoodDetailInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let foodItem: FoodItem
    let selectedDate: Date
    
    @State private var selectedMealType: MealType = .lunch
    @State private var servingAmount: Double = 100.0
    @State private var customCalories: Double
    @State private var customProtein: Double
    @State private var customFat: Double
    @State private var customCarbohydrates: Double
    @State private var isCustomMode: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(foodItem: FoodItem, selectedDate: Date) {
        self.foodItem = foodItem
        self.selectedDate = selectedDate
        // 初期値を食材のデータで設定
        self._customCalories = State(initialValue: foodItem.nutrition.calories)
        self._customProtein = State(initialValue: foodItem.nutrition.protein)
        self._customFat = State(initialValue: foodItem.nutrition.fat)
        self._customCarbohydrates = State(initialValue: foodItem.nutrition.carbohydrates)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 食材情報
                Section("食材情報") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(foodItem.name)
                            .font(.headline)
                        
                        if let category = foodItem.category {
                            Text("カテゴリ: \(category)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let brand = foodItem.brand {
                            Text("ブランド: \(brand)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 食事タイプ選択
                Section("食事タイプ") {
                    Picker("食事タイプ", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.displayName).tag(mealType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 入力モード選択
                Section("栄養情報入力") {
                    Toggle("手動で栄養情報を入力", isOn: $isCustomMode)
                }
                
                if !isCustomMode {
                    // 分量調整モード
                    Section("分量") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("分量")
                                Spacer()
                                Text("\(servingAmount, specifier: "%.0f")g")
                                    .fontWeight(.semibold)
                            }
                            
                            Slider(
                                value: $servingAmount,
                                in: 1...1000,
                                step: 1
                            ) {
                                Text("分量")
                            }
                            .accentColor(.purple)
                            
                            HStack {
                                Text("1g")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("1000g")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // 計算された栄養情報
                    Section("栄養情報（計算値）") {
                        let adjustedNutrition = foodItem.nutrition.scaled(to: servingAmount)
                        
                        NutritionInfoRow(
                            title: "カロリー",
                            value: "\(Int(adjustedNutrition.calories))kcal",
                            color: .orange
                        )
                        
                        NutritionInfoRow(
                            title: "たんぱく質",
                            value: "\(Int(adjustedNutrition.protein))g",
                            color: .red
                        )
                        
                        NutritionInfoRow(
                            title: "脂質",
                            value: "\(Int(adjustedNutrition.fat))g",
                            color: .orange
                        )
                        
                        NutritionInfoRow(
                            title: "炭水化物",
                            value: "\(Int(adjustedNutrition.carbohydrates))g",
                            color: .blue
                        )
                    }
                } else {
                    // 手動入力モード
                    Section("栄養情報（手動入力）") {
                        HStack {
                            Text("カロリー")
                            Spacer()
                            TextField("0", value: $customCalories, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                            Text("kcal")
                        }
                        
                        HStack {
                            Text("たんぱく質")
                            Spacer()
                            TextField("0", value: $customProtein, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                            Text("g")
                        }
                        
                        HStack {
                            Text("脂質")
                            Spacer()
                            TextField("0", value: $customFat, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                            Text("g")
                        }
                        
                        HStack {
                            Text("炭水化物")
                            Spacer()
                            TextField("0", value: $customCarbohydrates, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                            Text("g")
                        }
                    }
                    
                    Section {
                        Text("※ 手動入力モードでは、実際に摂取した栄養値を直接入力してください")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                    if alertMessage.contains("成功") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func saveFoodItem() {
        do {
            let nutritionToSave: NutritionInfo
            let amountToSave: Double
            
            if isCustomMode {
                // 手動入力の場合
                nutritionToSave = NutritionInfo(
                    calories: customCalories,
                    protein: customProtein,
                    fat: customFat,
                    carbohydrates: customCarbohydrates,
                    sugar: customCarbohydrates * 0.8, // 炭水化物の80%を糖質と仮定
                    servingSize: 100 // 手動入力の場合は100gとして記録
                )
                amountToSave = 100
            } else {
                // 分量調整の場合
                nutritionToSave = foodItem.nutrition
                amountToSave = servingAmount
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
struct FoodSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchView(selectedDate: Date())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
