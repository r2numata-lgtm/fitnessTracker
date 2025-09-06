//
//  FoodEntry+CoreDataProperties.swift
//  FitnessTracker
//
//  Updated for nutrition support on 2025/09/06.
//
import Foundation
import CoreData

extension FoodEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodEntry> {
        return NSFetchRequest<FoodEntry>(entityName: "FoodEntry")
    }

    // 既存フィールド
    @NSManaged public var date: Date
    @NSManaged public var foodName: String?
    @NSManaged public var calories: Double
    @NSManaged public var mealType: String?
    @NSManaged public var photo: Data?
    
    // 新規栄養素フィールド
    @NSManaged public var protein: Double           // たんぱく質(g)
    @NSManaged public var fat: Double               // 脂質(g)
    @NSManaged public var carbohydrates: Double     // 炭水化物(g)
    @NSManaged public var sugar: Double             // 糖質(g)
    @NSManaged public var servingSize: Double       // 分量(g)
    @NSManaged public var fiber: Double             // 食物繊維(g) - デフォルト0
    @NSManaged public var sodium: Double            // ナトリウム(mg) - デフォルト0
}

extension FoodEntry : Identifiable {

}

// MARK: - FoodEntry Extensions for Nutrition

extension FoodEntry {
    /// NutritionInfoからFoodEntryを作成
    convenience init(context: NSManagedObjectContext,
                    name: String,
                    nutrition: NutritionInfo,
                    mealType: String,
                    date: Date,
                    photo: Data? = nil) {
        self.init(context: context)
        self.foodName = name
        self.calories = nutrition.calories
        self.protein = nutrition.protein
        self.fat = nutrition.fat
        self.carbohydrates = nutrition.carbohydrates
        self.sugar = nutrition.sugar
        self.servingSize = nutrition.servingSize
        self.fiber = nutrition.fiber ?? 0
        self.sodium = nutrition.sodium ?? 0
        self.mealType = mealType
        self.date = date
        self.photo = photo
    }
    
    /// FoodEntryからNutritionInfoに変換
    var nutritionInfo: NutritionInfo {
        return NutritionInfo(
            calories: calories,
            protein: protein,
            fat: fat,
            carbohydrates: carbohydrates,
            sugar: sugar,
            servingSize: servingSize,
            fiber: fiber > 0 ? fiber : nil,
            sodium: sodium > 0 ? sodium : nil
        )
    }
    
    /// 表示用の完全な食品名
    var displayName: String {
        return foodName ?? "不明な食品"
    }
    
    /// 100gあたりのカロリー
    var caloriesPer100g: Double {
        guard servingSize > 0 else { return calories }
        return calories * (100.0 / servingSize)
    }
}

// MARK: - Migration Helper

extension FoodEntry {
    /// 既存データの栄養素フィールドを初期化（マイグレーション用）
    func initializeNutritionFields() {
        guard protein == 0 && fat == 0 && carbohydrates == 0 else {
            return // 既に初期化済み
        }
        
        // カロリーから簡易的に栄養素を推定
        // 注意: これは非常に簡易的な推定です
        let estimatedProtein = calories * 0.15 / 4  // カロリーの15%をたんぱく質と仮定
        let estimatedFat = calories * 0.25 / 9      // カロリーの25%を脂質と仮定
        let estimatedCarbs = calories * 0.60 / 4    // カロリーの60%を炭水化物と仮定
        
        self.protein = estimatedProtein
        self.fat = estimatedFat
        self.carbohydrates = estimatedCarbs
        self.sugar = estimatedCarbs * 0.8  // 炭水化物の80%を糖質と仮定
        self.servingSize = 100  // デフォルト100g
        self.fiber = 0
        self.sodium = 0
    }
}
