//
//  BodyComposition+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/27.
//
import Foundation
import CoreData

extension BodyComposition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BodyComposition> {
        return NSFetchRequest<BodyComposition>(entityName: "BodyComposition")
    }

    @NSManaged public var date: Date
    @NSManaged public var height: Double
    @NSManaged public var weight: Double
    @NSManaged public var bodyFatPercentage: Double
    @NSManaged public var basalMetabolicRate: Double

}

extension BodyComposition : Identifiable {

}
