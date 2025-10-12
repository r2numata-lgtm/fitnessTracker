//
//  NutritionSummaryCard.swift
//  FitnessTracker
//  Views/Food/Home/NutritionSummaryCard.swift
//

import SwiftUI
import CoreData

// MARK: - 栄養素サマリーカード
struct NutritionSummaryCard: View {
    let foods: [FoodRecord]
    
    private var totalProtein: Double {
        foods.reduce(0) { $0 + $1.actualProtein }
    }
    
    private var totalFat: Double {
        foods.reduce(0) { $0 + $1.actualFat }
    }
    
    private var totalCarbohydrates: Double {
        foods.reduce(0) { $0 + $1.actualCarbohydrates }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("栄養素")
                .font(.headline)
            
            HStack(spacing: 20) {
                NutritionItem(label: "たんぱく質", value: totalProtein, color: .red)
                NutritionItem(label: "脂質", value: totalFat, color: .yellow)
                NutritionItem(label: "炭水化物", value: totalCarbohydrates, color: .green)
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
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(Int(value))g")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NutritionSummaryCard(foods: [])
        .padding()
}
