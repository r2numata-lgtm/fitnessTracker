//
//  NutritionCard.swift
//  FitnessTracker
//  Views/Food/Home/NutritionCard.swift
//

import SwiftUI
import CoreData

// MARK: - 栄養素表示カード
struct NutritionCard: View {
    let foods: [FoodRecord]
    let onShowAll: (() -> Void)?
    
    init(foods: [FoodRecord], onShowAll: (() -> Void)? = nil) {
        self.foods = foods
        self.onShowAll = onShowAll
    }
    
    private var totalNutrition: (
        protein: Double,
        fat: Double,
        carbs: Double,
        sugar: Double,
        fiber: Double,
        sodium: Double
    ) {
        let protein = foods.reduce(0) { $0 + $1.actualProtein }
        let fat = foods.reduce(0) { $0 + $1.actualFat }
        let carbs = foods.reduce(0) { $0 + $1.actualCarbohydrates }
        let sugar = foods.reduce(0) { $0 + $1.actualSugar }
        
        // FoodMaster から食物繊維とナトリウムを取得
        let fiber = foods.reduce(0.0) { sum, food in
            sum + (food.foodMaster?.fiber ?? 0) * food.servingMultiplier
        }
        let sodium = foods.reduce(0.0) { sum, food in
            sum + (food.foodMaster?.sodium ?? 0) * food.servingMultiplier
        }
        
        return (protein, fat, carbs, sugar, fiber, sodium)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("栄養素")
                    .font(.headline)
                
                Spacer()
                
                if let onShowAll = onShowAll {
                    Button(action: onShowAll) {
                        HStack(spacing: 4) {
                            Text("すべて表示")
                                .font(.caption)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            // 主要栄養素（3列）
            HStack(spacing: 12) {
                NutritionItem(
                    label: "たんぱく質",
                    value: totalNutrition.protein,
                    unit: "g",
                    color: .red
                )
                
                NutritionItem(
                    label: "脂質",
                    value: totalNutrition.fat,
                    unit: "g",
                    color: .orange
                )
                
                NutritionItem(
                    label: "炭水化物",
                    value: totalNutrition.carbs,
                    unit: "g",
                    color: .blue
                )
            }
            
            // 詳細栄養素（3列）
            HStack(spacing: 12) {
                NutritionItem(
                    label: "糖質",
                    value: totalNutrition.sugar,
                    unit: "g",
                    color: .purple
                )
                
                NutritionItem(
                    label: "食物繊維",
                    value: totalNutrition.fiber,
                    unit: "g",
                    color: .green
                )
                
                NutritionItem(
                    label: "食塩相当量",
                    value: totalNutrition.sodium,
                    unit: "g",  // mgからgに変更
                    color: .gray
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 栄養素アイテム
struct NutritionItem: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value < 1 ? String(format: "%.1f", value) : "\(Int(value))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NutritionCard(
        foods: [],
        onShowAll: { print("すべて表示タップ") }
    )
    .padding()
}
