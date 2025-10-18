//
//  IntegratedSearchManager.swift
//  FitnessTracker
//  Models/Managers/IntegratedSearchManager.swift
//

import Foundation

/// 統合検索マネージャー（ローカル標準食品 + ユーザー投稿）
class IntegratedSearchManager {
    
    static let shared = IntegratedSearchManager()
    
    private let localFoods = LocalFoodsManager.shared
    private let sharedProducts = SharedProductManager.shared
    
    private init() {}
    

    // MARK: - 食材名検索
    
    /// 食材名統合検索（標準データベース + ユーザー投稿データベース）
    func searchFoodByName(_ name: String) async -> [FoodSearchResult] {
        print("=== 統合食材検索開始 ===")
        print("検索名: \(name)")
        
        var results: [FoodSearchResult] = []
        
        // 1. 標準食品データベースから検索（ローカル・高速）
        do {
            let standardProducts = localFoods.search(name)
            results.append(contentsOf: standardProducts.map { .shared($0) })
            print("✅ 標準DBから \(standardProducts.count) 件取得")
        } catch {
            print("⚠️ 標準DB検索エラー: \(error)")
        }
        
        // 2. ユーザー投稿データベースから検索（Firestore）
        do {
            let userProducts = try await sharedProducts.searchByName(name)
            results.append(contentsOf: userProducts.map { .shared($0) })
            print("✅ ユーザーDBから \(userProducts.count) 件取得")
        } catch {
            print("⚠️ ユーザーDB検索エラー: \(error)")
        }
        
        // 信頼度順ソート（標準データが優先される）
        let sortedResults = results.sorted { $0.trustScore > $1.trustScore }
        
        print("✅ 統合検索結果: \(sortedResults.count)件")
        return sortedResults
    }
    
    // MARK: - 手動入力保存
    
    /// 手動入力された食材をユーザーDBに保存
    func saveManualEntry(
        name: String,
        nutrition: NutritionInfo,
        category: String? = nil,
        brand: String? = nil,
        barcode: String? = nil
    ) async throws {
        do {
            let userId = try await sharedProducts.authenticateAnonymously()
            
            let sharedProduct = SharedProduct(
                barcode: barcode,
                name: name,
                brand: brand,
                nutrition: nutrition,
                category: category,
                contributorId: userId
            )
            
            try await sharedProducts.submitProduct(sharedProduct)
            print("✅ 手動入力をユーザーDBに保存: \(name)")
            
        } catch {
            print("❌ ユーザーDB保存エラー: \(error)")
            throw error
        }
    }
    
}

// MARK: - 検索結果の統合型
enum FoodSearchResult: Identifiable {
    case local(FoodItem)
    case shared(SharedProduct)
    
    var id: String {
        switch self {
        case .local(let food):
            return "local_\(food.id)"
        case .shared(let product):
            return "shared_\(product.id)"
        }
    }
    
    var name: String {
        switch self {
        case .local(let food):
            return food.name
        case .shared(let product):
            return product.name
        }
    }
    
    var nutrition: NutritionInfo {
        switch self {
        case .local(let food):
            return food.nutrition
        case .shared(let product):
            return product.nutrition
        }
    }
    
    var category: String? {
        switch self {
        case .local(let food):
            return food.category
        case .shared(let product):
            return product.category
        }
    }
    
    var source: String {
        switch self {
        case .local:
            return "基本食材"
        case .shared(let product):
            return "投稿データ (信頼度: \(Int(product.trustScore * 100))%)"
        }
    }
    
    var trustScore: Double {
        switch self {
        case .local:
            return 1.0  // ローカルデータは100%信頼
        case .shared(let product):
            return product.trustScore
        }
    }
}
