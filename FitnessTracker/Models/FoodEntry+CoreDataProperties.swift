//
//  FoodEntry+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/27.
//
import Foundation
import CoreData

extension FoodEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodEntry> {
        return NSFetchRequest<FoodEntry>(entityName: "FoodEntry")
    }

    @NSManaged public var date: Date
    @NSManaged public var foodName: String?
    @NSManaged public var calories: Double
    @NSManaged public var mealType: String?
    @NSManaged public var photo: Data?

}

extension FoodEntry : Identifiable {

}
