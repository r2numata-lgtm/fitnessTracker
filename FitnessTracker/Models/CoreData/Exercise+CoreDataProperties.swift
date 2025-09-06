//
//  Exercise+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/17.
//
import Foundation
import CoreData

extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var isCustom: Bool
    @NSManaged public var createdAt: Date

}

extension Exercise : Identifiable {

}
