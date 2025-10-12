//
//  FoodSearchView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/FoodSearchView.swift
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
    @State private var selectedFoodResult: FoodSearchResult?
    @State private var favoriteFoods: [FoodItem] = []
    @State private var showingManualInput = false  // ← 追加
    
    var body: some View {
        NavigationView {
            ZStack {  // ← 追加：フローティングボタンのため
                VStack(spacing: 0) {
                    searchBar
                    
                    if searchText.isEmpty {
                        favoriteFoodsSection
                    } else {
                        searchResultsSection
                    }
                }
                
                // ← 追加：右下のフローティングボタン
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(action: {
                            showingManualInput = true
                        })
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("食材検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(item: $selectedFoodResult) { result in
                FoodDetailInputView(
                    foodResult: result,
                    selectedDate: selectedDate,
                    onSaved: loadFavorites
                )
                .environment(\.managedObjectContext, viewContext)
            }
            // ← 追加：手動入力シート
            .sheet(isPresented: $showingManualInput) {
                FoodDetailInputView(
                    foodResult: .local(FoodItem(
                        name: "",  // 空の食材名でスタート
                        nutrition: NutritionInfo(
                            calories: 0,
                            protein: 0,
                            fat: 0,
                            carbohydrates: 0,
                            sugar: 0,
                            servingSize: 100
                        ),
                        category: "カスタム"
                    )),
                    selectedDate: selectedDate,
                    onSaved: loadFavorites
                )
                .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                loadFavorites()
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchBar: some View {
        SearchBarView(
            searchText: $searchText,
            onSubmit: performSearch,
            onClear: clearSearch
        )
    }
    
    private var favoriteFoodsSection: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                sectionHeader
                
                if favoriteFoods.isEmpty {
                    EmptyFavoritesView()
                } else {
                    favoriteFoodsList
                }
                
                // ← 追加：スクロール用の余白（ボタンと重ならないように）
                Spacer(minLength: 80)
            }
            .padding(.vertical)
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("よく使う食材")
                .font(.headline)
            
            Spacer()
            
            Text("\(favoriteFoods.count)品目")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private var favoriteFoodsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(favoriteFoods, id: \.id) { food in
                FavoriteFoodRow(
                    food: food,
                    onTap: { selectFavoriteFood(food) },
                    onDelete: { deleteFavoriteFood(food) }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var searchResultsSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isSearching {
                    searchingIndicator
                } else if searchResults.isEmpty {
                    emptySearchResultView
                } else {
                    searchResultsList
                }
                
                // ← 追加：スクロール用の余白
                Spacer(minLength: 80)
            }
            .padding()
        }
    }
    
    private var searchingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("ユーザー投稿データベースを検索中...")
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var emptySearchResultView: some View {
        EmptySearchResultView(onManualAdd: createCustomFood)
    }
    
    private var searchResultsList: some View {
        ForEach(searchResults, id: \.id) { result in
            FoodSearchResultRow(result: result) {
                selectedFoodResult = result
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
    }
    
    // MARK: - Functions
    
    private func loadFavorites() {
        favoriteFoods = FavoriteFoodManager.shared.getFavorites()
        print("✅ よく使う食材を読み込み: \(favoriteFoods.count)件")
    }
    
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
    
    private func clearSearch() {
        searchText = ""
        searchResults = []
    }
    
    private func createCustomFood() {
        print("=== 手動追加開始 ===")
        print("食材名: \(searchText)")
        
        let customFood = FoodItem(
            name: searchText,
            nutrition: NutritionInfo(
                calories: 0,
                protein: 0,
                fat: 0,
                carbohydrates: 0,
                sugar: 0,
                servingSize: 100
            ),
            category: "カスタム"
        )
        
        print("servingSize: \(customFood.nutrition.servingSize)")
        
        selectedFoodResult = .local(customFood)
    }
    
    private func selectFavoriteFood(_ food: FoodItem) {
        print("=== よく使う食材タップ ===")
        print("食材名: \(food.name)")
        print("カロリー: \(food.nutrition.calories)")
        print("servingSize: \(food.nutrition.servingSize)")
        
        selectedFoodResult = .local(food)
    }
    
    private func deleteFavoriteFood(_ food: FoodItem) {
        FavoriteFoodManager.shared.removeFavorite(food)
        loadFavorites()
    }
}

// MARK: - Preview

struct FoodSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FoodSearchView(selectedDate: Date())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
