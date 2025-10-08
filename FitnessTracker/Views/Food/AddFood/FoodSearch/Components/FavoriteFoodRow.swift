//
//  FavoriteFoodRow.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/Components/FavoriteFoodRow.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - よく使う食材行
struct FavoriteFoodRow: View {
    let food: FoodItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: {
            print("FavoriteFoodRowタップ: \(food.name)")
            onTap()
        }) {
            HStack(spacing: 12) {
                categoryIcon
                
                foodInfo
                
                Spacer()
                
                calorieInfo
                
                deleteButton
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Subviews
    
    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(categoryColor.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Text(food.name.prefix(1))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(categoryColor)
        }
    }
    
    private var foodInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(food.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            if let category = food.category {
                Text(category)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(categoryColor.opacity(0.2))
                    .foregroundColor(categoryColor)
                    .cornerRadius(4)
            }
        }
    }
    
    private var calorieInfo: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(Int(food.nutrition.calories))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text("kcal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            print("削除ボタンタップ: \(food.name)")
            onDelete()
        }) {
            Image(systemName: "trash.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
                .padding(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper
    
    private var categoryColor: Color {
        switch food.category {
        case "肉類": return .red
        case "魚介類": return .blue
        case "野菜": return .green
        case "果物": return .orange
        case "穀物": return .brown
        case "乳製品": return .purple
        default: return .gray
        }
    }
}

#Preview {
    List {
        FavoriteFoodRow(
            food: FoodItem(
                name: "鶏胸肉（皮なし）",
                nutrition: NutritionInfo(
                    calories: 191,
                    protein: 23.3,
                    fat: 1.9,
                    carbohydrates: 0,
                    sugar: 0
                ),
                category: "肉類"
            ),
            onTap: { print("タップ") },
            onDelete: { print("削除") }
        )
    }
}
