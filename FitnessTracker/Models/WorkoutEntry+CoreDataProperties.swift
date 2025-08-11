//
//  WorkoutEntry+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/27.
//
import Foundation
import CoreData

extension WorkoutEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntry> {
        return NSFetchRequest<WorkoutEntry>(entityName: "WorkoutEntry")
    }

    @NSManaged public var date: Date
    @NSManaged public var exerciseName: String?
    @NSManaged public var weight: Double
    @NSManaged public var sets: Int16
    @NSManaged public var reps: Int16
    @NSManaged public var caloriesBurned: Double
    @NSManaged public var photo: Data?
    @NSManaged public var memo: String?

}

extension WorkoutEntry : Identifiable {

}
