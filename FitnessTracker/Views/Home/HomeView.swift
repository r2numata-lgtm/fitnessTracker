//
//  HomeView.swift
//  FitnessTracker
//  Views/Home/HomeView.swift
//
//  Updated on 2025/10/19.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var healthKitManager: HealthKitManager
    
    @State private var dailyCalories: DailyCalories?
    @State private var todayWorkouts: [WorkoutEntry] = []
    @State private var todayFoods: [FoodRecord] = []
    @State private var selectedDate = Date()
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 日付選択ヘッダー
                    DatePickerHeader(
                        selectedDate: $selectedDate,
                        onDateChanged: {
                            loadTodayData()
                            refreshID = UUID()
                        }
                    )
                    .padding(.horizontal)
                    
                    CalorieBalanceCard(
                        selectedDate: selectedDate,
                        dailyCalories: dailyCalories,
                        todayWorkouts: todayWorkouts,
                        todayFoods: todayFoods
                    )
                    .id(refreshID)
                    
                    if !todayWorkouts.isEmpty {
                        TodayWorkoutSummaryCard(workouts: todayWorkouts)
                            .id(refreshID)
                    }
                    
                    if !todayFoods.isEmpty {
                        TodayFoodSummaryCard(foods: todayFoods)
                            .id(refreshID)
                    }
                    
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
            .onChange(of: viewContext.hasChanges) { _ in
                if !viewContext.hasChanges {
                    loadTodayData()
                    updateDailyCalories()
                    refreshID = UUID()
                }
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
        if dailyCalories == nil {
            createTodayCaloriesEntry()
        }
        
        let totalIntake = todayFoods.reduce(0) { $0 + $1.actualCalories }
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
