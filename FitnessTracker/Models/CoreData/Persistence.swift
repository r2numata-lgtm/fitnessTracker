//
//  Persistence.swift
//  FitnessTracker
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
        
        // FoodEntry → FoodRecord に変更
        let sampleFoodMaster = FoodMaster(context: viewContext)
        sampleFoodMaster.id = UUID()
        sampleFoodMaster.name = "鶏胸肉"
        sampleFoodMaster.calories = 191
        sampleFoodMaster.protein = 23.3
        sampleFoodMaster.fat = 1.9
        sampleFoodMaster.carbohydrates = 0
        sampleFoodMaster.sugar = 0
        sampleFoodMaster.fiber = 0
        sampleFoodMaster.sodium = 0
        sampleFoodMaster.createdAt = Date()
        
        let sampleFoodRecord = FoodRecord(context: viewContext)
        sampleFoodRecord.id = UUID()
        sampleFoodRecord.date = Date()
        sampleFoodRecord.mealType = "昼食"
        sampleFoodRecord.servingMultiplier = 1.0
        sampleFoodRecord.actualCalories = 191
        sampleFoodRecord.actualProtein = 23.3
        sampleFoodRecord.actualFat = 1.9
        sampleFoodRecord.actualCarbohydrates = 0
        sampleFoodRecord.actualSugar = 0
        sampleFoodRecord.foodMaster = sampleFoodMaster
        
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
