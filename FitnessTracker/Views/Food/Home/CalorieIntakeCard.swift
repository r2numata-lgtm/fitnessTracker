//
//  CalorieIntakeCard.swift
//  FitnessTracker
//  Views/Food/Home/CalorieIntakeCard.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 摂取カロリーカード
struct CalorieIntakeCard: View {
    let foods: [FoodEntry]
    
    private var totalCalories: Double {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("摂取カロリー")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(Int(totalCalories))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("kcal")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}
