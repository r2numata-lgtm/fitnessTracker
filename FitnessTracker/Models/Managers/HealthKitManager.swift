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
    @Published var dailyDistance: Double = 0  // 追加
    @Published var dailyActiveCalories: Double = 0  // 追加
    
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
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,  // 追加
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
                    self?.fetchTodayActivityData()
                    self?.startObservingActivityData()
                }
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 今日のアクティビティデータを取得（統合版）
    func fetchTodayActivityData() {
        fetchTodaySteps()
        fetchTodayDistance()
        fetchTodayActiveCalories()
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
                    print("✅ 歩数取得: \(steps)歩")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - 移動距離データ取得
    func fetchTodayDistance() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("距離取得エラー: \(error.localizedDescription)")
                    return
                }
                
                if let sum = result?.sumQuantity() {
                    let distanceInKm = sum.doubleValue(for: HKUnit.meter()) / 1000.0
                    self?.dailyDistance = distanceInKm
                    print("✅ 移動距離取得: \(String(format: "%.2f", distanceInKm))km")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - 活動消費カロリー取得（Apple Watch優先）
    func fetchTodayActiveCalories() {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: caloriesType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("消費カロリー取得エラー: \(error.localizedDescription)")
                    return
                }
                
                if let sum = result?.sumQuantity() {
                    let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                    self?.dailyActiveCalories = calories
                    print("✅ 活動消費カロリー取得: \(Int(calories))kcal (Apple Watchデータ)")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - アクティビティデータの監視
    private func startObservingActivityData() {
        startObservingSteps()
        startObservingDistance()
        startObservingActiveCalories()
    }
    
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
    
    private func startObservingDistance() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: distanceType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("距離監視エラー: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchTodayDistance()
            }
        }
        
        healthStore.execute(query)
    }
    
    private func startObservingActiveCalories() {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: caloriesType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("消費カロリー監視エラー: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchTodayActiveCalories()
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - 最適な活動代謝を計算（ハイブリッド方式）
    func calculateOptimalActivityCalories(weight: Double, activityLevel: ActivityLevel?) -> Double {
        // 優先順位1: Apple Watchの活動消費カロリー（最も正確）
        if dailyActiveCalories > 0 {
            print("🏆 Apple Watch活動カロリー使用: \(Int(dailyActiveCalories))kcal")
            return dailyActiveCalories
        }
        
        // 優先順位2: 移動距離ベースの計算（正確）
        if dailyDistance > 0 {
            let calories = calculateActivityCaloriesFromDistance(distance: dailyDistance, weight: weight)
            print("✅ 距離ベース計算: \(String(format: "%.2f", dailyDistance))km → \(Int(calories))kcal")
            return calories
        }
        
        // 優先順位3: 歩数から距離を推定（まあまあ）
        if dailySteps > 0 {
            let estimatedDistance = Double(dailySteps) * 0.0007 // 1歩 = 約0.7m
            let calories = calculateActivityCaloriesFromDistance(distance: estimatedDistance, weight: weight)
            print("⚠️ 歩数から推定: \(dailySteps)歩 → \(String(format: "%.2f", estimatedDistance))km → \(Int(calories))kcal")
            return calories
        }
        
        // 優先順位4: 活動レベル係数（フォールバック）
        if let level = activityLevel {
            print("⚠️ 活動レベル係数使用: \(level.rawValue)")
            // この場合は基礎代謝 × 係数で計算するため、CalorieBalanceCardで処理
            return 0
        }
        
        print("❌ 活動データなし")
        return 0
    }
    
    // MARK: - 距離ベースの活動代謝計算
    private func calculateActivityCaloriesFromDistance(distance: Double, weight: Double) -> Double {
        // 計算式: 体重(kg) × 距離(km) × 1.05
        return weight * distance * 1.05
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
