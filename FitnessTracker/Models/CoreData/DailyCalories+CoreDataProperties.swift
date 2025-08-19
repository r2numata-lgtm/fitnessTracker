//
//  DailyCalories+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/27.
//
import Foundation
import CoreData

extension DailyCalories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyCalories> {
        return NSFetchRequest<DailyCalories>(entityName: "DailyCalories")
    }

    @NSManaged public var date: Date
    @NSManaged public var totalIntake: Double
    @NSManaged public var totalBurned: Double
    @NSManaged public var netCalories: Double
    @NSManaged public var steps: Int32

}

extension DailyCalories : Identifiable {

}
