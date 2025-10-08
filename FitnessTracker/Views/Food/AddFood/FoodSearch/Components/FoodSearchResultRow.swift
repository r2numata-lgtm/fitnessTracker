//
//  FoodSearchResultRow.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/Components/FoodSearchResultRow.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - 統合検索結果行
struct FoodSearchResultRow: View {
    let result: FoodSearchResult
    var showCategory: Bool = true
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                categoryIcon
                
                foodInfo
                
                Spacer()
                
                calorieInfo
                
                chevron
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
            
            Text(result.name.prefix(1))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(categoryColor)
        }
    }
    
    private var foodInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                sourceTag
                
                if showCategory, let category = result.category {
                    categoryTag(category)
                }
            }
        }
    }
    
    private var sourceTag: some View {
        Text(result.source)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(sourceColor.opacity(0.2))
            .foregroundColor(sourceColor)
            .cornerRadius(4)
    }
    
    private func categoryTag(_ category: String) -> some View {
        Text(category)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(4)
    }
    
    private var calorieInfo: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(Int(result.nutrition.calories))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text("kcal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    // MARK: - Helpers
    
    private var categoryColor: Color {
        switch result.category {
        case "肉類": return .red
        case "魚介類": return .blue
        case "野菜": return .green
        case "果物": return .orange
        case "穀物": return .brown
        case "乳製品": return .purple
        default: return .gray
        }
    }
    
    private var sourceColor: Color {
        switch result.source {
        case let s where s.contains("基本食材"): return .blue
        case let s where s.contains("投稿データ"): return .green
        default: return .gray
        }
    }
}

#Preview {
    List {
        FoodSearchResultRow(
            result: .local(FoodItem(
                name: "白米",
                nutrition: NutritionInfo(
                    calories: 356,
                    protein: 6.1,
                    fat: 0.9,
                    carbohydrates: 77.6,
                    sugar: 77.6
                ),
                category: "穀物"
            )),
            onTap: { print("タップ") }
        )
    }
}
