//
//  FoodRecordManager.swift
//  FitnessTracker
//  Models/Managers/FoodRecordManager.swift
//
//  Created by 沼田蓮二朗 on 2025/09/07.
//

import Foundation
import CoreData

class FoodRecordManager {
    
    /// 食事記録を保存
    static func saveFoodRecord(
        context: NSManagedObjectContext,
        name: String,
        nutrition: NutritionInfo,
        servingMultiplier: Double,
        mealType: MealType,
        date: Date,
        category: String? = nil,
        photo: Data? = nil
    ) throws {
        
        // 1. 食材マスタを取得または作成
        let foodMaster = FoodMasterManager.findOrCreateFoodMaster(
            name: name,
            nutrition: nutrition,
            category: category,
            photo: photo,
            context: context
        )
        
        // 2. 実際に食べた栄養情報を計算
        let actualNutrition = foodMaster.nutritionInfo.scaled(to: 100.0 * servingMultiplier)
        
        // 3. 食事記録を作成
        let record = FoodRecord(context: context)
        record.id = UUID()
        record.date = date
        record.mealType = mealType.rawValue
        record.servingMultiplier = servingMultiplier
        record.actualCalories = actualNutrition.calories
        record.actualProtein = actualNutrition.protein
        record.actualFat = actualNutrition.fat
        record.actualCarbohydrates = actualNutrition.carbohydrates
        record.actualSugar = actualNutrition.sugar
        record.foodMaster = foodMaster
        
        try context.save()
        print("✅ 食事記録を保存: \(name) \(servingMultiplier)人前")
    }
    
    /// 日付範囲で食事記録を取得
    static func getFoodRecords(
        from startDate: Date,
        to endDate: Date,
        context: NSManagedObjectContext
    ) -> [FoodRecord] {
        let fetchRequest: NSFetchRequest<FoodRecord> = FoodRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startDate as NSDate,
            endDate as NSDate
        )
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \FoodRecord.date, ascending: false)
        ]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("⚠️ 食事記録取得エラー: \(error)")
            return []
        }
    }
    
    /// 今日の食事記録を取得
    static func getTodayFoodRecords(
        context: NSManagedObjectContext
    ) -> [FoodRecord] {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return getFoodRecords(from: startOfDay, to: endOfDay, context: context)
    }
    
    /// 食事タイプ別に取得
    static func getFoodRecords(
        mealType: MealType,
        date: Date,
        context: NSManagedObjectContext
    ) -> [FoodRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<FoodRecord> = FoodRecord.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate),
            NSPredicate(format: "mealType == %@", mealType.rawValue)
        ])
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \FoodRecord.date, ascending: true)
        ]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("⚠️ 食事記録取得エラー: \(error)")
            return []
        }
    }
}
