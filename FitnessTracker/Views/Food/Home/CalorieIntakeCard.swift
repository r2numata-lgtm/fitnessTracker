//
//  CalorieIntakeCard.swift
//  FitnessTracker
//  Views/Food/Home/CalorieIntakeCard.swift
//

import SwiftUI
import CoreData

// MARK: - 摂取カロリーカード
struct CalorieIntakeCard: View {
    let foods: [FoodRecord]  // FoodEntry → FoodRecord
    
    private var totalCalories: Double {
        foods.reduce(0) { $0 + $1.actualCalories }  // calories → actualCalories
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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return CalorieIntakeCard(foods: [])
        .environment(\.managedObjectContext, context)
}
