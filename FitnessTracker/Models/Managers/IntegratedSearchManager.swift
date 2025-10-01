//
//  IntegratedSearchManager.swift
//  FitnessTracker
//  Models/Managers/IntegratedSearchManager.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation

class IntegratedSearchManager {
    
    static let shared = IntegratedSearchManager()
    private init() {}
    
    /// バーコード統合検索（ユーザーDB → OpenFoodFacts API の順）
    func searchProductByBarcode(_ barcode: String) async throws -> BarcodeProduct? {
        print("=== 統合バーコード検索開始 ===")
        print("バーコード: \(barcode)")
        
        // 1. ユーザー投稿データベースを最初に検索
        do {
            if let sharedProduct = try await SharedProductManager.shared.searchByBarcode(barcode) {
                print("✅ ユーザーDBで発見: \(sharedProduct.name)")
                return convertToBarcodeProduct(from: sharedProduct)
            }
        } catch {
            print("⚠️ ユーザーDB検索エラー: \(error)")
        }
        
        // 2. OpenFoodFacts APIで検索
        do {
            if let apiProduct = try await BarcodeAPIManager.shared.searchProduct(barcode: barcode) {
                print("✅ OpenFoodFactsで発見: \(apiProduct.name)")
                
                // 見つかった商品をユーザーDBに自動保存
                await saveToUserDatabase(apiProduct: apiProduct, barcode: barcode)
                
                return apiProduct
            }
        } catch {
            print("⚠️ OpenFoodFacts検索エラー: \(error)")
        }
        
        print("❌ バーコード検索：すべてのソースで見つかりませんでした")
        return nil
    }
    
    /// 食材名統合検索（ユーザーDBのみ）
    func searchFoodByName(_ name: String) async -> [FoodSearchResult] {
        print("=== 統合食材検索開始 ===")
        print("検索名: \(name)")
        
        var results: [FoodSearchResult] = []
        
        // ユーザー投稿データベースのみから検索
        do {
            let sharedProducts = try await SharedProductManager.shared.searchByName(name)
            results.append(contentsOf: sharedProducts.map { .shared($0) })
        } catch {
            print("⚠️ ユーザーDB検索エラー: \(error)")
        }
        
        // 信頼度順ソート
        let sortedResults = results.sorted { $0.trustScore > $1.trustScore }
        
        print("✅ 統合検索結果: \(sortedResults.count)件")
        return sortedResults
    }
    
    /// 手動入力された食材をユーザーDBに保存
    func saveManualEntry(
        name: String,
        nutrition: NutritionInfo,
        category: String? = nil,
        brand: String? = nil,
        barcode: String? = nil
    ) async throws {
        do {
            let userId = try await SharedProductManager.shared.authenticateAnonymously()
            
            let sharedProduct = SharedProduct(
                barcode: barcode,
                name: name,
                brand: brand,
                nutrition: nutrition,
                category: category,
                contributorId: userId
            )
            
            try await SharedProductManager.shared.submitProduct(sharedProduct)
            print("✅ 手動入力をユーザーDBに保存: \(name)")
            
        } catch {
            print("❌ ユーザーDB保存エラー: \(error)")
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func convertToBarcodeProduct(from sharedProduct: SharedProduct) -> BarcodeProduct {
        return BarcodeProduct(
            barcode: sharedProduct.barcode ?? "",
            name: sharedProduct.name,
            brand: sharedProduct.brand,
            nutrition: sharedProduct.nutrition,
            imageURL: sharedProduct.imageURL,
            category: sharedProduct.category,
            packageSize: sharedProduct.packageSize,
            description: "信頼度: \(Int(sharedProduct.trustScore * 100))% | 投稿データ"
        )
    }
    
    private func saveToUserDatabase(apiProduct: BarcodeProduct, barcode: String) async {
        do {
            // 既に同じバーコードの商品が存在するかチェック
            if let existingProduct = try await SharedProductManager.shared.searchByBarcode(barcode) {
                print("⚠️ 既にユーザーDBに存在するためスキップ: \(existingProduct.name)")
                return
            }
            
            let userId = try await SharedProductManager.shared.authenticateAnonymously()
            
            let sharedProduct = SharedProduct(
                barcode: barcode,
                name: apiProduct.name,
                brand: apiProduct.brand,
                nutrition: apiProduct.nutrition,
                category: apiProduct.category,
                packageSize: apiProduct.packageSize,
                imageURL: apiProduct.imageURL,
                description: "OpenFoodFactsより自動取得",
                contributorId: userId
            )
            
            try await SharedProductManager.shared.submitProduct(sharedProduct)
            print("✅ API取得商品をユーザーDBに自動保存")
            
        } catch {
            print("⚠️ API商品の自動保存失敗: \(error)")
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
