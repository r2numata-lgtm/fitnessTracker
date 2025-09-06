//
//  FoodSaveManager.swift
//  FitnessTracker
//  Models/Managers/FoodSaveManager.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation
import CoreData

// MARK: - 食事保存管理
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
        let foodEntry = FoodEntry(
            context: context,
            name: name,
            nutrition: nutrition,
            mealType: mealType.rawValue,
            date: date,
            photo: photo
        )
        
        try context.save()
        print("食事記録を保存しました: \(name)")
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
            let foodEntry = FoodEntry(
                context: context,
                name: food.name,
                nutrition: food.nutrition,
                mealType: mealType.rawValue,
                date: date,
                photo: photo
            )
        }
        
        try context.save()
        print("複数の食事記録を保存しました: \(foods.count)品目")
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
        // 指定されたグラム数に調整
        let adjustedNutrition = foodItem.nutrition.scaled(to: amount)
        
        try saveFoodEntry(
            context: context,
            name: foodItem.name,
            nutrition: adjustedNutrition,
            mealType: mealType,
            date: date,
            photo: photo
        )
    }
    
    /// BarcodeProductをCore Dataに保存
    static func saveBarcodeProduct(
        context: NSManagedObjectContext,
        product: BarcodeProduct,
        amount: Double,
        mealType: MealType,
        date: Date,
        photo: Data? = nil
    ) throws {
        // 指定されたグラム数に調整
        let adjustedNutrition = product.nutrition.scaled(to: amount)
        
        try saveFoodEntry(
            context: context,
            name: product.fullDisplayName,
            nutrition: adjustedNutrition,
            mealType: mealType,
            date: date,
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
        
        let foodsToSave = includedFoods.map { food in
            (name: food.name, nutrition: food.nutrition)
        }
        
        try saveMultipleFoodEntries(
            context: context,
            foods: foodsToSave,
            mealType: mealType,
            date: date,
            photo: photo
        )
    }
    
    /// 既存データの栄養素フィールドを初期化（マイグレーション用）
    static func initializeExistingData(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        
        do {
            let existingEntries = try context.fetch(fetchRequest)
            
            var updatedCount = 0
            for entry in existingEntries {
                if entry.protein == 0 && entry.fat == 0 && entry.carbohydrates == 0 {
                    entry.initializeNutritionFields()
                    updatedCount += 1
                }
            }
            
            if updatedCount > 0 {
                try context.save()
                print("既存データの栄養素フィールドを初期化しました: \(updatedCount)件")
            }
            
        } catch {
            print("既存データの初期化エラー: \(error)")
        }
    }
    
    /// 日付別の栄養素合計を取得
    static func getTotalNutrition(
        context: NSManagedObjectContext,
        for date: Date
    ) -> NutritionInfo {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            let entries = try context.fetch(fetchRequest)
            return entries.reduce(NutritionInfo.empty) { total, entry in
                total + entry.nutritionInfo
            }
        } catch {
            print("栄養素合計取得エラー: \(error)")
            return NutritionInfo.empty
        }
    }
}

// MARK: - EditableDetectedFood (PhotoResultViewで使用)

struct EditableDetectedFood: Identifiable {
    let id = UUID()
    var name: String
    var estimatedWeight: Double
    var nutrition: NutritionInfo
    let confidence: Double
    var isIncluded: Bool
    
    var displayWeight: String {
        if estimatedWeight >= 1000 {
            return String(format: "%.1fkg", estimatedWeight / 1000)
        } else {
            return String(format: "%.0fg", estimatedWeight)
        }
    }
}
