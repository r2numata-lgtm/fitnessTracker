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

// MARK: - カロリー収支カード（修正版）
struct CalorieBalanceCard: View {
    let dailyCalories: DailyCalories?
    let todayWorkouts: [WorkoutEntry]
    let todayFoods: [FoodEntry]
    
    private var totalIntake: Double {
        todayFoods.reduce(0) { $0 + $1.calories }
    }
    
    private var totalBurned: Double {
        todayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    private var netCalories: Double {
        totalIntake - totalBurned
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("今日のカロリー収支")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(Int(netCalories))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(netCalories > 0 ? .red : .green)
            
            Text("kcal")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Divider()
            
            HStack {
                VStack {
                    Text("摂取")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(totalIntake))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack {
                    Text("消費")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(totalBurned))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                VStack {
                    Text("歩数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(dailyCalories?.steps ?? 0)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 今日の筋トレサマリーカード
struct TodayWorkoutSummaryCard: View {
    let workouts: [WorkoutEntry]
    
    private var groupedWorkouts: [String: [WorkoutEntry]] {
        Dictionary(grouping: workouts) { workout in
            workout.exerciseName ?? "不明な種目"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("今日の筋トレ")
                .font(.headline)
            
            ForEach(Array(groupedWorkouts.keys.sorted()), id: \.self) { exerciseName in
                if let exerciseWorkouts = groupedWorkouts[exerciseName] {
                    WorkoutSummaryRow(exerciseName: exerciseName, workouts: exerciseWorkouts)
                }
            }
            
            // 合計表示
            HStack {
                Text("合計")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(groupedWorkouts.keys.count)種目")
                    .foregroundColor(.secondary)
                Text("\(Int(workouts.reduce(0) { $0 + $1.caloriesBurned }))kcal")
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 筋トレサマリー行
struct WorkoutSummaryRow: View {
    let exerciseName: String
    let workouts: [WorkoutEntry]
    
    var body: some View {
        HStack {
            Image(systemName: "dumbbell.fill")
                .foregroundColor(.orange)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(workouts.count)セット")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(workouts.reduce(0) { $0 + $1.caloriesBurned }))kcal")
                .font(.caption)
                .foregroundColor(.orange)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - 今日の食事サマリーカード
struct TodayFoodSummaryCard: View {
    let foods: [FoodEntry]
    
    private var groupedFoods: [String: [FoodEntry]] {
        Dictionary(grouping: foods) { food in
            food.mealType ?? "その他"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("今日の食事")
                .font(.headline)
            
            ForEach(["朝食", "昼食", "夕食", "間食"], id: \.self) { mealType in
                if let mealFoods = groupedFoods[mealType], !mealFoods.isEmpty {
                    FoodSummaryRow(mealType: mealType, foods: mealFoods)
                }
            }
            
            // 合計表示
            HStack {
                Text("合計")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(foods.count)品目")
                    .foregroundColor(.secondary)
                Text("\(Int(foods.reduce(0) { $0 + $1.calories }))kcal")
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 食事サマリー行
struct FoodSummaryRow: View {
    let mealType: String
    let foods: [FoodEntry]
    
    var body: some View {
        HStack {
            Image(systemName: "fork.knife")
                .foregroundColor(.green)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mealType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(foods.count)品目")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(foods.reduce(0) { $0 + $1.calories }))kcal")
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - 空の状態カード
struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("今日の記録はまだありません")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("筋トレや食事を記録して\n健康管理を始めましょう！")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(HealthKitManager())
    }
}
