//
//  ContentView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            // ホーム画面 - HomeView.swift を使用
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            // 筋トレ画面
            WorkoutView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("筋トレ")
                }
            
            // 食事画面
            FoodView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("食事")
                }
            
            // 体組成画面
            BodyCompositionView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("体組成")
                }
            
            // 設定画面
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
        .environment(\.managedObjectContext, viewContext)
    }
}

// MARK: - 設定画面（簡易版）
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("基本設定") {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("プロフィール設定")
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("通知設定")
                    }
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("データエクスポート")
                    }
                }
                
                Section("その他") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("ヘルプ")
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                        Text("アプリについて")
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(HealthKitManager())
    }
}
