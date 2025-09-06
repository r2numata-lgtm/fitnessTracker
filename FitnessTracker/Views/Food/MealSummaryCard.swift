//
//  MealSummaryCard.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 食事カロリーまとめカード
struct MealSummaryCard: View {
    let foods: [FoodEntry]
    let onMealTapped: (String) -> Void
    
    private var mealData: [(String, Double, Color)] {
        let mealTypes = ["朝食", "昼食", "夕食", "間食"]
        return mealTypes.map { mealType in
            let calories = foods.filter { $0.mealType == mealType }.reduce(0) { $0 + $1.calories }
            let color: Color = {
                switch mealType {
                case "朝食": return .orange
                case "昼食": return .green
                case "夕食": return .blue
                default: return .purple
                }
            }()
            return (mealType, calories, color)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("今日の食事")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(mealData, id: \.0) { meal in
                    MealSummaryItem(
                        mealType: meal.0,
                        calories: meal.1,
                        color: meal.2,
                        foods: foods.filter { $0.mealType == meal.0 }
                    ) {
                        onMealTapped(meal.0)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 食事サマリーアイテム
struct MealSummaryItem: View {
    let mealType: String
    let calories: Double
    let color: Color
    let foods: [FoodEntry]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // アイコンエリア
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: mealIcon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(color)
                    )
                
                // 食事タイプ
                Text(mealType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // カロリー
                Text("\(Int(calories))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text("kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var mealIcon: String {
        switch mealType {
        case "朝食": return "sunrise.fill"
        case "昼食": return "sun.max.fill"
        case "夕食": return "moon.fill"
        default: return "heart.fill"
        }
    }
}
