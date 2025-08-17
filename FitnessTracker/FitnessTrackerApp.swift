//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI

@main
struct FitnessTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(healthKitManager)
                .onAppear {
                    // アプリ起動時の初期設定
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // 通知の許可を求める
        requestNotificationPermission()
        
        // 日次カロリー更新のスケジュール設定
        scheduleCalorieUpdates()
        
        // デフォルト種目の初期化を追加
        ExerciseManager.initializeDefaultExercises(context: persistenceController.container.viewContext)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("通知許可エラー: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleCalorieUpdates() {
        // 毎日午後11時に日次カロリーを更新
        let content = UNMutableNotificationContent()
        content.title = "今日のカロリー収支"
        content.body = "今日の記録を確認しましょう"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 23
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyCalorieUpdate", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - カロリー計算ヘルパークラス
class CalorieCalculator {
    
    // MARK: - 基礎代謝計算（Harris-Benedict式）
    static func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        switch gender {
        case .male:
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case .female:
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    // MARK: - 筋トレ消費カロリー計算
    static func calculateWorkoutCalories(exerciseName: String, weight: Double, sets: Int, reps: Int) -> Double {
        let metValues: [String: Double] = [
            "ベンチプレス": 6.0,
            "インクラインベンチプレス": 6.5,
            "スクワット": 5.0,
            "デッドリフト": 6.0,
            "懸垂": 8.0,
            "腕立て伏せ": 3.8,
            "ショルダープレス": 4.0,
            "ラットプルダウン": 4.5,
            "ランニング": 8.0,
            "ウォーキング": 3.5,
            "サイクリング": 7.0,
            "水泳": 8.0
        ]
        
        let metValue = metValues[exerciseName] ?? 5.0
        let estimatedDurationHours = Double(sets * reps) / 60.0 // 1分あたり1回と仮定
        
        return metValue * weight * estimatedDurationHours
    }
    
    // MARK: - 歩数消費カロリー計算
    static func calculateStepsCalories(steps: Int, weight: Double) -> Double {
        return Double(steps) * weight * 0.04
    }
    
    // MARK: - BMI計算
    static func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    // MARK: - 理想体重計算
    static func calculateIdealWeight(height: Double) -> Double {
        let heightInMeters = height / 100.0
        return 22.0 * heightInMeters * heightInMeters // BMI 22を基準
    }
    
    // MARK: - 活動代謝計算
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }
}

// MARK: - 拡張機能
extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay())!
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func daysBetween(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - UserDefaults拡張
extension UserDefaults {
    enum Keys: String {
        case userHeight = "userHeight"
        case userWeight = "userWeight"
        case userAge = "userAge"
        case userGender = "userGender"
        case dailyCalorieGoal = "dailyCalorieGoal"
        case lastSyncDate = "lastSyncDate"
    }
    
    func set(_ value: Any?, forKey key: Keys) {
        set(value, forKey: key.rawValue)
    }
    
    func object(forKey key: Keys) -> Any? {
        return object(forKey: key.rawValue)
    }
    
    func double(forKey key: Keys) -> Double {
        return double(forKey: key.rawValue)
    }
    
    func integer(forKey key: Keys) -> Int {
        return integer(forKey: key.rawValue)
    }
    
    func string(forKey key: Keys) -> String? {
        return string(forKey: key.rawValue)
    }
}
