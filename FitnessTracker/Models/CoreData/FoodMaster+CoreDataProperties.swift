//
//  FoodMaster+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/09/07.
//

import Foundation
import CoreData

extension FoodMaster {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodMaster> {
        return NSFetchRequest<FoodMaster>(entityName: "FoodMaster")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var calories: Double
    @NSManaged public var protein: Double
    @NSManaged public var fat: Double
    @NSManaged public var carbohydrates: Double
    @NSManaged public var sugar: Double
    @NSManaged public var fiber: Double
    @NSManaged public var sodium: Double
    @NSManaged public var category: String?
    @NSManaged public var photo: Data?
    @NSManaged public var createdAt: Date
    @NSManaged public var records: NSSet?

}

// MARK: Generated accessors for records
extension FoodMaster {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: FoodRecord)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: FoodRecord)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension FoodMaster : Identifiable {
    
    /// 100g基準の栄養情報
    var nutritionInfo: NutritionInfo {
        return NutritionInfo(
            calories: calories,
            protein: protein,
            fat: fat,
            carbohydrates: carbohydrates,
            sugar: sugar,
            servingSize: 100.0,
            fiber: fiber > 0 ? fiber : nil,
            sodium: sodium > 0 ? sodium : nil
        )
    }
}
