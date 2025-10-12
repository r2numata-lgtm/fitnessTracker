//
//  MealTypeCard.swift
//  FitnessTracker
//  Views/Food/Home/MealTypeCard.swift
//

import SwiftUI
import CoreData

// MARK: - 食事タイプ別カード
struct MealTypeCard: View {
    let mealType: MealType
    let foods: [FoodRecord]
    
    private var totalCalories: Double {
        foods.reduce(0) { $0 + $1.actualCalories }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: mealType.icon)
                    .foregroundColor(mealType.color)
                Text(mealType.displayName)
                    .font(.headline)
                Spacer()
                Text("\(Int(totalCalories))kcal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(mealType.color)
            }
            
            if !foods.isEmpty {
                ForEach(foods, id: \.id) { food in
                    FoodRecordRow(food: food)
                }
            } else {
                Text("記録なし")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - 食事記録行
struct FoodRecordRow: View {
    let food: FoodRecord
    
    var body: some View {
        HStack {
            Text(food.foodName)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(Int(food.actualCalories))kcal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - MealType Extension
extension MealType {
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "cup.and.saucer.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .blue
        case .snack: return .purple
        }
    }
}

#Preview {
    MealTypeCard(mealType: .lunch, foods: [])
        .padding()
}
