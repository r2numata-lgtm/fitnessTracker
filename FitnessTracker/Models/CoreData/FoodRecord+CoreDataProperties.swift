//
//  FoodRecord+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/09/07.
//

import Foundation
import CoreData

extension FoodRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodRecord> {
        return NSFetchRequest<FoodRecord>(entityName: "FoodRecord")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var mealType: String
    @NSManaged public var servingMultiplier: Double
    @NSManaged public var actualCalories: Double
    @NSManaged public var actualProtein: Double
    @NSManaged public var actualFat: Double
    @NSManaged public var actualCarbohydrates: Double
    @NSManaged public var actualSugar: Double
    @NSManaged public var foodMaster: FoodMaster?

}

extension FoodRecord : Identifiable {
    
    /// 実際に食べた栄養情報
    var nutritionInfo: NutritionInfo {
        return NutritionInfo(
            calories: actualCalories,
            protein: actualProtein,
            fat: actualFat,
            carbohydrates: actualCarbohydrates,
            sugar: actualSugar,
            servingSize: 100.0 * servingMultiplier
        )
    }
    
    /// 食材名（FoodMasterから取得）
    var foodName: String {
        return foodMaster?.name ?? "不明な食材"
    }
    
    /// 写真（FoodMasterから取得）
    var photo: Data? {
        return foodMaster?.photo
    }
}
