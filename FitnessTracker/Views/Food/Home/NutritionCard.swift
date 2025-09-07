//
//  NutritionCard.swift
//  FitnessTracker
//  Views/Food/Home/NutritionCard.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 栄養素カード
struct NutritionCard: View {
    let foods: [FoodEntry]
    
    // 実際の栄養素データから計算
    private var nutritionData: [(String, Double, String, Color)] {
        let totalNutrition = calculateTotalNutrition()
        
        return [
            ("たんぱく質", totalNutrition.protein, "g", .red),
            ("脂質", totalNutrition.fat, "g", .orange),
            ("炭水化物", totalNutrition.carbohydrates, "g", .blue),
            ("糖質", totalNutrition.sugar, "g", .purple)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("栄養素")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(nutritionData, id: \.0) { nutrition in
                    NutritionItem(
                        name: nutrition.0,
                        value: nutrition.1,
                        unit: nutrition.2,
                        color: nutrition.3
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - Private Methods
    
    private func calculateTotalNutrition() -> NutritionInfo {
        return foods.reduce(NutritionInfo.empty) { total, food in
            total + food.nutritionInfo
        }
    }
}

// MARK: - 栄養素アイテム
struct NutritionItem: View {
    let name: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(value, specifier: "%.1f")")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
