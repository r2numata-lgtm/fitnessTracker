//
//  HealthKitManager.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import HealthKit
import Foundation

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    @Published var dailySteps: Int = 0
    
    init() {
        checkHealthKitAvailability()
    }
    
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        requestHealthKitPermissions()
    }
    
    private func requestHealthKitPermissions() {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            HKQuantityType.quantityType(forIdentifier: .height)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.fetchTodaySteps()
                    self?.startObservingSteps()
                }
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 歩数データ取得
    func fetchTodaySteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("歩数取得エラー: \(error.localizedDescription)")
                    return
                }
                
                if let sum = result?.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    self?.dailySteps = steps
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - 歩数データの監視
    private func startObservingSteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: stepsType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("歩数監視エラー: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchTodaySteps()
            }
        }
        
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: stepsType, frequency: .immediate) { success, error in
            if let error = error {
                print("バックグラウンド配信エラー: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 消費カロリー取得
    func fetchTodayActiveCalories(completion: @escaping (Double) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: caloriesType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("消費カロリー取得エラー: \(error.localizedDescription)")
                    completion(0)
                    return
                }
                
                if let sum = result?.sumQuantity() {
                    let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                    completion(calories)
                } else {
                    completion(0)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - 体重データをHealthKitに保存
    func saveWeightToHealthKit(_ weight: Double, date: Date = Date()) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return
        }
        
        let weightQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let weightSample = HKQuantitySample(type: weightType,
                                          quantity: weightQuantity,
                                          start: date,
                                          end: date)
        
        healthStore.save(weightSample) { success, error in
            if let error = error {
                print("体重保存エラー: \(error.localizedDescription)")
            } else {
                print("体重をHealthKitに保存しました")
            }
        }
    }
    
    // MARK: - 運動データをHealthKitに保存
    func saveWorkoutToHealthKit(exerciseName: String, calories: Double, startDate: Date, duration: TimeInterval) {
        let workoutType = mapExerciseToWorkoutType(exerciseName)
        
        let workout = HKWorkout(activityType: workoutType,
                              start: startDate,
                              end: startDate.addingTimeInterval(duration),
                              duration: duration,
                              totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
                              totalDistance: nil,
                              metadata: [HKMetadataKeyExternalUUID: UUID().uuidString])
        
        healthStore.save(workout) { success, error in
            if let error = error {
                print("ワークアウト保存エラー: \(error.localizedDescription)")
            } else {
                print("ワークアウトをHealthKitに保存しました")
            }
        }
    }
    
    private func mapExerciseToWorkoutType(_ exerciseName: String) -> HKWorkoutActivityType {
        switch exerciseName {
        case "ランニング":
            return .running
        case "ウォーキング":
            return .walking
        case "サイクリング":
            return .cycling
        case "水泳":
            return .swimming
        default:
            return .traditionalStrengthTraining
        }
    }
    
    // MARK: - 歩数からカロリー計算
    func calculateCaloriesFromSteps(_ steps: Int, bodyWeight: Double = 70.0) -> Double {
        // 一般的な計算式: 歩数 × 体重(kg) × 0.04
        return Double(steps) * bodyWeight * 0.04
    }
    
    // MARK: - 週間データ取得
    func fetchWeeklySteps(completion: @escaping ([Int]) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: now, options: .strictStartDate)
        
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: stepsType,
                                               quantitySamplePredicate: predicate,
                                               options: .cumulativeSum,
                                               anchorDate: sevenDaysAgo,
                                               intervalComponents: interval)
        
        query.initialResultsHandler = { _, results, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("週間歩数取得エラー: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var weeklySteps: [Int] = []
                
                results?.enumerateStatistics(from: sevenDaysAgo, to: now) { statistics, _ in
                    let steps = Int(statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
                    weeklySteps.append(steps)
                }
                
                completion(weeklySteps)
            }
        }
        
        healthStore.execute(query)
    }
}
