//
//  FavoriteFoodManager.swift
//  FitnessTracker
//  Models/Managers/FavoriteFoodManager.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation

class FavoriteFoodManager: ObservableObject {
    
    static let shared = FavoriteFoodManager()
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favoriteFoods"
    
    // MARK: - お気に入り管理
    
    /// お気に入り食材を取得
    func getFavorites() -> [FoodItem] {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            print("⚠️ お気に入り食材が見つかりません")
            return [] // 空の配列を返す
        }
        print("✅ お気に入り食材を読み込み: \(favorites.count)件")
        return favorites
    }
    
    /// お気に入りに追加
    func addFavorite(_ foodItem: FoodItem) {
        var favorites = getFavorites()
        
        // 重複チェック
        if !favorites.contains(where: { $0.name == foodItem.name }) {
            favorites.insert(foodItem, at: 0)
            saveFavorites(favorites)
            print("✅ お気に入りに追加: \(foodItem.name)")
        } else {
            print("⚠️ 既にお気に入りに存在: \(foodItem.name)")
        }
    }
    
    /// お気に入りから削除
    func removeFavorite(_ foodItem: FoodItem) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == foodItem.id }
        saveFavorites(favorites)
        print("✅ お気に入りから削除: \(foodItem.name)")
    }
    
    /// お気に入りかどうか判定
    func isFavorite(_ foodItem: FoodItem) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.name == foodItem.name }
    }
    
    /// 全てのお気に入りをクリア（デバッグ用）
    func clearAllFavorites() {
        userDefaults.removeObject(forKey: favoritesKey)
        print("✅ お気に入りを全てクリアしました")
    }
    
    // MARK: - Private Methods
    
    private func saveFavorites(_ favorites: [FoodItem]) {
        do {
            let data = try JSONEncoder().encode(favorites)
            userDefaults.set(data, forKey: favoritesKey)
            print("✅ お気に入りを保存: \(favorites.count)件")
        } catch {
            print("❌ お気に入り保存エラー: \(error)")
        }
    }
}
