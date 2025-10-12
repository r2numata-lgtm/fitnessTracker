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
    let foods: [FoodRecord]  // FoodEntry → FoodRecord に変更
    
    // 実際の栄養素データから計算
    private var nutritionData: [(String, Double, String, Color)] {
        let totalProtein = foods.reduce(0) { $0 + $1.actualProtein }
        let totalFat = foods.reduce(0) { $0 + $1.actualFat }
        let totalCarbs = foods.reduce(0) { $0 + $1.actualCarbohydrates }
        let totalSugar = foods.reduce(0) { $0 + $1.actualSugar }
        
        return [
            ("たんぱく質", totalProtein, "g", .red),
            ("脂質", totalFat, "g", .orange),
            ("炭水化物", totalCarbs, "g", .blue),
            ("糖質", totalSugar, "g", .purple)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("栄養素")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(nutritionData, id: \.0) { nutrition in
                    NutritionCardItem(
                        label: nutrition.0,
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
}

// MARK: - 栄養素アイテム
struct NutritionCardItem: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
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

#Preview {
    NutritionCard(foods: [])
        .padding()
}
