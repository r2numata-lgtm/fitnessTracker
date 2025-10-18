//
//  LocalFoodsManager.swift
//  FitnessTracker
//  Models/Managers/LocalFoodsManager.swift
//

import Foundation

/// ローカルバンドルされた標準食品データベース管理
class LocalFoodsManager {
    
    static let shared = LocalFoodsManager()
    
    // MARK: - Properties
    
    private var allFoods: [SharedProduct] = []
    private var foodsByCategory: [String: [SharedProduct]] = [:]
    private var isLoaded = false
    
    private init() {
        loadFoodsFromBundle()
    }
    
    // MARK: - Public Methods
    
    /// 検索（超高速・読み取りゼロ）
    func search(_ query: String) -> [SharedProduct] {
        guard !query.isEmpty else { return [] }
        
        let normalizedQuery = normalizeForSearch(query)
        
        let results = allFoods.filter { food in
            let normalizedName = normalizeForSearch(food.name)
            return normalizedName.contains(normalizedQuery)
        }
        
        print("🔍 ローカル検索: '\(query)' → \(results.count)件（0.01秒未満）")
        return Array(results.prefix(50))
    }
    
    /// カテゴリで検索
    func searchByCategory(_ category: String) -> [SharedProduct] {
        return foodsByCategory[category] ?? []
    }
    
    /// すべてのカテゴリを取得
    func getAllCategories() -> [String] {
        return Array(foodsByCategory.keys).sorted()
    }
    
    /// 完全一致検索
    func searchExact(_ query: String) -> SharedProduct? {
        return allFoods.first { $0.name == query }
    }
    
    /// 人気食品トップN
    func getPopularFoods(limit: Int = 50) -> [SharedProduct] {
        return Array(allFoods
            .sorted { $0.verificationCount > $1.verificationCount }
            .prefix(limit))
    }
    
    /// すべての食品を取得
    func getAllFoods() -> [SharedProduct] {
        return allFoods
    }
    
    // MARK: - Private Methods
    
    private func loadFoodsFromBundle() {
        guard !isLoaded else { return }
        
        let startTime = Date()
        
        // Bundleから標準食品JSONを読み込み
        guard let url = Bundle.main.url(forResource: "standard_foods", withExtension: "json") else {
            print("❌ standard_foods.json が見つかりません")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            allFoods = try decoder.decode([SharedProduct].self, from: data)
            
            // カテゴリ別にインデックス化
            for food in allFoods {
                if let category = food.category {
                    if foodsByCategory[category] == nil {
                        foodsByCategory[category] = []
                    }
                    foodsByCategory[category]?.append(food)
                }
            }
            
            isLoaded = true
            
            let loadTime = Date().timeIntervalSince(startTime)
            print("✅ ローカル食品データベース読み込み完了")
            print("   食品数: \(allFoods.count)件")
            print("   カテゴリ数: \(foodsByCategory.count)個")
            print("   読み込み時間: \(String(format: "%.3f", loadTime))秒")
            
        } catch {
            print("❌ 標準食品JSONの読み込みエラー: \(error)")
        }
    }
    
    private func normalizeForSearch(_ text: String) -> String {
        return text
            .lowercased()
            .replacingOccurrences(of: "　", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "（", with: "")
            .replacingOccurrences(of: "）", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .applyingTransform(.hiraganaToKatakana, reverse: false) ?? text
    }
}
