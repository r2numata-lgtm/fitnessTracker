//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct FitnessTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var healthKitManager = HealthKitManager()
    
    init() {
        FirebaseApp.configure()  // この行を追加
    }
    
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
        
        // Firebase接続テスト（デバッグ用）
        testFirebaseConnection()
    }
    
    private func testFirebaseConnection() {
        let db = Firestore.firestore()
        
        // テストドキュメントを作成
        db.collection("test").document("connection").setData([
            "timestamp": Date(),
            "message": "Firebase接続成功"
        ]) { error in
            if let error = error {
                print("❌ Firebase接続エラー: \(error)")
            } else {
                print("✅ Firebase接続成功")
                
                Task {
                    await testSharedProductManager()
                }
            }
        }
    }
    
    private func testSharedProductManager() async {
        do {
            let userId = try await SharedProductManager.shared.authenticateAnonymously()
            print("✅ 匿名認証成功: \(userId)")
            
            // テスト商品を作成
            let testNutrition = NutritionInfo(
                calories: 100,
                protein: 2.0,
                fat: 1.0,
                carbohydrates: 20.0,
                sugar: 15.0,
                servingSize: 100
            )
            
            let testProduct = SharedProduct(
                barcode: "test123456789",
                name: "テスト商品",
                brand: "テストブランド",
                nutrition: testNutrition,
                category: "テスト",
                contributorId: userId
            )
            
            try await SharedProductManager.shared.submitProduct(testProduct)
            print("✅ テスト商品投稿成功")
            
        } catch {
            print("❌ SharedProductManagerテストエラー: \(error)")
        }
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
