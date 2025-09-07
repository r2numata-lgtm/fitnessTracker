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
        
        // デフォルト種目の初期化
        ExerciseManager.initializeDefaultExercises(context: persistenceController.container.viewContext)
        
        // 既存食事データの栄養素フィールド初期化
        FoodSaveManager.initializeExistingData(context: persistenceController.container.viewContext)
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
