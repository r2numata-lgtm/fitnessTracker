//
//  FoodMasterManager.swift
//  FitnessTracker
//  Models/Managers/FoodMasterManager.swift
//

import Foundation
import CoreData

class FoodMasterManager {
    
    /// 食材マスタを検索または作成
    static func findOrCreateFoodMaster(
        name: String,
        nutrition: NutritionInfo,
        category: String? = nil,
        photo: Data? = nil,
        context: NSManagedObjectContext
    ) -> FoodMaster {
        
        // 既存の食材マスタを検索
        let fetchRequest: NSFetchRequest<FoodMaster> = FoodMaster.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        
        do {
            if let existingMaster = try context.fetch(fetchRequest).first {
                print("✅ 既存の食材マスタを使用: \(name)")
                
                // 写真がない場合は更新
                if existingMaster.photo == nil && photo != nil {
                    existingMaster.photo = photo
                }
                
                return existingMaster
            }
        } catch {
            print("⚠️ 食材マスタ検索エラー: \(error)")
        }
        
        // 100g基準に正規化
        let baseNutrition = nutrition.normalized()
        
        // 新規作成
        let newMaster = FoodMaster(context: context)
        newMaster.id = UUID()
        newMaster.name = name
        newMaster.calories = baseNutrition.calories
        newMaster.protein = baseNutrition.protein
        newMaster.fat = baseNutrition.fat
        newMaster.carbohydrates = baseNutrition.carbohydrates
        newMaster.sugar = baseNutrition.sugar
        newMaster.fiber = baseNutrition.fiber ?? 0
        newMaster.sodium = baseNutrition.sodium ?? 0
        newMaster.category = category
        newMaster.photo = photo
        newMaster.createdAt = Date()
        
        print("✅ 新規食材マスタを作成: \(name)")
        return newMaster
    }
    
    /// 食材マスタの一覧を取得（重複なし）
    static func getAllFoodMasters(context: NSManagedObjectContext) -> [FoodMaster] {
        let fetchRequest: NSFetchRequest<FoodMaster> = FoodMaster.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \FoodMaster.name, ascending: true)
        ]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("⚠️ 食材マスタ取得エラー: \(error)")
            return []
        }
    }
    
    /// 食材名で検索（改善版：ひらがな・カタカナ・漢字を区別しない）
    static func searchFoodMasters(
        name: String,
        context: NSManagedObjectContext
    ) -> [FoodMaster] {
        let fetchRequest: NSFetchRequest<FoodMaster> = FoodMaster.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \FoodMaster.name, ascending: true)
        ]
        
        do {
            let allMasters = try context.fetch(fetchRequest)
            
            // ← 改善：正規化して検索
            let normalizedSearchTerm = name.lowercased()
                .applyingTransform(.hiraganaToKatakana, reverse: false) ?? name
            
            let filtered = allMasters.filter { master in
                let normalizedMasterName = master.name.lowercased()
                    .applyingTransform(.hiraganaToKatakana, reverse: false) ?? master.name
                
                return normalizedMasterName.contains(normalizedSearchTerm)
            }
            
            print("✅ 食材マスタ検索: \(name) → \(filtered.count)件")
            return filtered
            
        } catch {
            print("⚠️ 食材マスタ検索エラー: \(error)")
            return []
        }
    }
}
