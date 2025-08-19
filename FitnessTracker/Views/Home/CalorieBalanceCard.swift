//
//  CalorieBalanceCard.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import SwiftUI

// MARK: - カロリー収支カード
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
