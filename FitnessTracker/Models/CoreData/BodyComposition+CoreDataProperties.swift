//
//  BodyComposition+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/10/19.
//
import Foundation
import CoreData

extension BodyComposition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BodyComposition> {
        return NSFetchRequest<BodyComposition>(entityName: "BodyComposition")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var height: Double
    @NSManaged public var weight: Double
    @NSManaged public var age: Int16
    @NSManaged public var gender: String
    @NSManaged public var bodyFatPercentage: Double
    @NSManaged public var muscleMass: Double
    @NSManaged public var basalMetabolicRate: Double
    @NSManaged public var activityLevel: String?

}

extension BodyComposition : Identifiable {

}
