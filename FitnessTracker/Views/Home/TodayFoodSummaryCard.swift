//
//  TodayFoodSummaryCard.swift
//  FitnessTracker
//

import SwiftUI

// MARK: - 今日の食事サマリーカード
struct TodayFoodSummaryCard: View {
    let foods: [FoodRecord]  // FoodEntry → FoodRecord
    
    private var groupedFoods: [String: [FoodRecord]] {
        Dictionary(grouping: foods) { food in
            food.mealType
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
                Text("\(Int(foods.reduce(0) { $0 + $1.actualCalories }))kcal")  // calories → actualCalories
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
    let foods: [FoodRecord]  // FoodEntry → FoodRecord
    
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
            
            Text("\(Int(foods.reduce(0) { $0 + $1.actualCalories }))kcal")  // calories → actualCalories
                .font(.caption)
                .foregroundColor(.green)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    TodayFoodSummaryCard(foods: [])
        .padding()
}
