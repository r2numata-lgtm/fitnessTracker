//
//  TodayFoodSummaryCard.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import SwiftUI

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
