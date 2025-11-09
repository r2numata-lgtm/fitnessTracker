//
//  WorkoutPhoto+CoreDataProperties.swift
//  FitnessTracker
//

import Foundation
import CoreData

extension WorkoutPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutPhoto> {
        return NSFetchRequest<WorkoutPhoto>(entityName: "WorkoutPhoto")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageData: Data?
    @NSManaged public var date: Date?
    @NSManaged public var createdAt: Date?
}

extension WorkoutPhoto : Identifiable {
    // 安全なアクセス用のプロパティ
    public var wrappedId: UUID {
        return id ?? UUID()
    }
    
    public var wrappedDate: Date {
        return date ?? Date()
    }
    
    public var wrappedCreatedAt: Date {
        return createdAt ?? Date()
    }
}
