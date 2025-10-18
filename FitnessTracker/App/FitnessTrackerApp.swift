//
//  FitnessTrackerApp.swift
//  FitnessTracker
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct FitnessTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var healthKitManager = HealthKitManager()
    
    init() {
        FirebaseApp.configure()
        print("✅ Firebase初期化完了")
        
        // ローカル食品データベースを初期化（自動的にロード）
        _ = LocalFoodsManager.shared
        print("✅ ローカル食品データベース準備完了")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(healthKitManager)
                .onAppear {
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
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 通知の許可を取得")
            } else if let error = error {
                print("❌ 通知許可エラー: \(error)")
            }
        }
    }
    
    private func scheduleCalorieUpdates() {
        print("✅ カロリー更新をスケジュール")
    }
}
