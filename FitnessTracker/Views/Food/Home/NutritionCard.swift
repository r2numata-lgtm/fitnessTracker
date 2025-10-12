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
    let onShowAll: (() -> Void)?  // ← 追加
    
    init(foods: [FoodRecord], onShowAll: (() -> Void)? = nil) {
        self.foods = foods
        self.onShowAll = onShowAll
    }
    
    private var totalNutrition: (protein: Double, fat: Double, carbs: Double) {
        let protein = foods.reduce(0) { $0 + $1.actualProtein }
        let fat = foods.reduce(0) { $0 + $1.actualFat }
        let carbs = foods.reduce(0) { $0 + $1.actualCarbohydrates }
        return (protein, fat, carbs)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("栄養素")
                    .font(.headline)
                
                Spacer()
                
                // ← 追加：すべて表示ボタン
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
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(value))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
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
