//
//  HomeView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/02.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var healthKitManager: HealthKitManager
    
    @State private var dailyCalories: DailyCalories?
    @State private var todayWorkouts: [WorkoutEntry] = []
    @State private var todayFoods: [FoodEntry] = []
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
        
        // 今日の食事データを取得
        let foodRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        foodRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                          startOfDay as NSDate,
                                          endOfDay as NSDate)
        foodRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: true)]
        
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
            
            print("デバッグ: 筋トレ記録数 = \(todayWorkouts.count)")
            for workout in todayWorkouts {
                print("デバッグ: 種目名 = \(workout.exerciseName ?? "nil")")
            }
            
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
        let totalIntake = todayFoods.reduce(0) { $0 + $1.calories }
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




struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(HealthKitManager())
    }
}
