//
//  Persistence.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // プレビュー用のサンプルデータ
        let sampleWorkout = WorkoutEntry(context: viewContext)
        sampleWorkout.date = Date()
        sampleWorkout.exerciseName = "ベンチプレス"
        sampleWorkout.weight = 80
        sampleWorkout.sets = 3
        sampleWorkout.reps = 10
        sampleWorkout.caloriesBurned = 150
        
        let sampleFood = FoodEntry(context: viewContext)
        sampleFood.date = Date()
        sampleFood.foodName = "鶏胸肉"
        sampleFood.calories = 200
        sampleFood.mealType = "昼食"
        
        let sampleBody = BodyComposition(context: viewContext)
        sampleBody.date = Date()
        sampleBody.height = 175
        sampleBody.weight = 70
        sampleBody.bodyFatPercentage = 15
        sampleBody.basalMetabolicRate = 1800
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FitnessTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                              forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
