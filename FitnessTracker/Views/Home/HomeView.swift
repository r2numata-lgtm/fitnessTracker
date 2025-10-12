//
//  HomeView.swift
//  FitnessTracker
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var healthKitManager: HealthKitManager
    
    @State private var dailyCalories: DailyCalories?
    @State private var todayWorkouts: [WorkoutEntry] = []
    @State private var todayFoods: [FoodRecord] = []  // FoodEntry → FoodRecord
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 日付選択
                    DatePicker("日付", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(.horizontal)
                        .onChange(of: selectedDate) { _ in
                            loadTodayData()
                        }
                    
                    // カロリー収支表示
                    CalorieBalanceCard(
                        dailyCalories: dailyCalories,
                        todayWorkouts: todayWorkouts,
                        todayFoods: todayFoods
                    )
                    
                    // 今日の筋トレ記録サマリー
                    if !todayWorkouts.isEmpty {
                        TodayWorkoutSummaryCard(workouts: todayWorkouts)
                    }
                    
                    // 今日の食事記録サマリー
                    if !todayFoods.isEmpty {
                        TodayFoodSummaryCard(foods: todayFoods)
                    }
                    
                    // データがない場合のメッセージ
                    if todayWorkouts.isEmpty && todayFoods.isEmpty {
                        EmptyStateCard()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("ホーム")
            .onAppear {
                loadTodayData()
                updateDailyCalories()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadTodayData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // 今日の筋トレデータを取得
        let workoutRequest: NSFetchRequest<WorkoutEntry> = WorkoutEntry.fetchRequest()
        workoutRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                             startOfDay as NSDate,
                                             endOfDay as NSDate)
        workoutRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: true)]
        
        // 今日の食事データを取得 (FoodRecord)
        let foodRequest: NSFetchRequest<FoodRecord> = FoodRecord.fetchRequest()
        foodRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                          startOfDay as NSDate,
                                          endOfDay as NSDate)
        foodRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FoodRecord.date, ascending: true)]
        
        // 今日のカロリーデータを取得
        let calorieRequest: NSFetchRequest<DailyCalories> = DailyCalories.fetchRequest()
        calorieRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                             startOfDay as NSDate,
                                             endOfDay as NSDate)
        
        do {
            todayWorkouts = try viewContext.fetch(workoutRequest)
            todayFoods = try viewContext.fetch(foodRequest)
            
            let calories = try viewContext.fetch(calorieRequest)
            dailyCalories = calories.first
            
        } catch {
            print("データ取得エラー: \(error)")
        }
    }
    
    private func updateDailyCalories() {
        // カロリーデータがない場合は作成
        if dailyCalories == nil {
            createTodayCaloriesEntry()
        }
        
        // 合計値を計算して更新
        let totalIntake = todayFoods.reduce(0) { $0 + $1.actualCalories }  // calories → actualCalories
        let totalBurned = todayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
        
        dailyCalories?.totalIntake = totalIntake
        dailyCalories?.totalBurned = totalBurned
        dailyCalories?.netCalories = totalIntake - totalBurned
        
        try? viewContext.save()
    }
    
    private func createTodayCaloriesEntry() {
        let newCalories = DailyCalories(context: viewContext)
        newCalories.date = selectedDate
        newCalories.totalIntake = 0
        newCalories.totalBurned = 0
        newCalories.netCalories = 0
        newCalories.steps = Int32(healthKitManager.dailySteps)
        
        try? viewContext.save()
        dailyCalories = newCalories
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(HealthKitManager())
}
