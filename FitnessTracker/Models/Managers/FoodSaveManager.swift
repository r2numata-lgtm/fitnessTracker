//
//  FoodSaveManager.swift
//  FitnessTracker
//  Models/Managers/FoodSaveManager.swift
//
//  Updated on 2025/09/07.
//

import Foundation
import CoreData

// MARK: - 食事保存管理（FoodMaster + FoodRecord対応版）
class FoodSaveManager {
    
    /// 単一食品をCore Dataに保存
    static func saveFoodEntry(
        context: NSManagedObjectContext,
        name: String,
        nutrition: NutritionInfo,
        mealType: MealType,
        date: Date,
        photo: Data? = nil
    ) throws {
        // servingMultiplierを計算（何人前か）
        let servingMultiplier = nutrition.servingSize / 100.0
        
        try FoodRecordManager.saveFoodRecord(
            context: context,
            name: name,
            nutrition: nutrition,
            servingMultiplier: servingMultiplier,
            mealType: mealType,
            date: date,
            photo: photo
        )
    }
    
    /// 複数食品をCore Dataに保存（写真解析結果など）
    static func saveMultipleFoodEntries(
        context: NSManagedObjectContext,
        foods: [(name: String, nutrition: NutritionInfo)],
        mealType: MealType,
        date: Date,
        photo: Data? = nil
    ) throws {
        for food in foods {
            let servingMultiplier = food.nutrition.servingSize / 100.0
            
            try FoodRecordManager.saveFoodRecord(
                context: context,
                name: food.name,
                nutrition: food.nutrition,
                servingMultiplier: servingMultiplier,
                mealType: mealType,
                date: date,
                photo: photo
            )
        }
        
        print("✅ 複数の食事記録を保存しました: \(foods.count)品目")
    }
    
    /// FoodItemをCore Dataに保存
    static func saveFoodItem(
        context: NSManagedObjectContext,
        foodItem: FoodItem,
        amount: Double,
        mealType: MealType,
        date: Date,
        photo: Data? = nil
    ) throws {
        let servingMultiplier = amount / 100.0
        
        try FoodRecordManager.saveFoodRecord(
            context: context,
            name: foodItem.name,
            nutrition: foodItem.nutrition,
            servingMultiplier: servingMultiplier,
            mealType: mealType,
            date: date,
            category: foodItem.category,
            photo: photo
        )
    }
    
    
    /// 写真解析結果をCore Dataに保存
    static func savePhotoAnalysisResult(
        context: NSManagedObjectContext,
        result: PhotoAnalysisResult,
        selectedFoods: [EditableDetectedFood],
        mealType: MealType,
        date: Date,
        photo: Data? = nil
    ) throws {
        let includedFoods = selectedFoods.filter { $0.isIncluded }
        
        for food in includedFoods {
            let servingMultiplier = food.estimatedWeight / 100.0
            
            try FoodRecordManager.saveFoodRecord(
                context: context,
                name: food.name,
                nutrition: food.nutrition,
                servingMultiplier: servingMultiplier,
                mealType: mealType,
                date: date,
                photo: photo
            )
        }
    }
    
    // ⚠️ 以下のマイグレーション関数は削除
    // migrateFromFoodEntry() は不要
    
    /// 日付別の栄養素合計を取得
    static func getTotalNutrition(
        context: NSManagedObjectContext,
        for date: Date
    ) -> NutritionInfo {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let records = FoodRecordManager.getFoodRecords(
            from: startOfDay,
            to: endOfDay,
            context: context
        )
        
        return records.reduce(NutritionInfo.empty) { total, record in
            total + record.nutritionInfo
        }
    }
}
