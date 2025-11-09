//
//  GroupedWorkoutRowView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import SwiftUI

// MARK: - グループ化された筋トレ行表示
struct GroupedWorkoutRowView: View {
    let exerciseName: String
    let workoutSets: [WorkoutEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exerciseName)
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(totalCalories))kcal")
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Label("合計: \(workoutSets.count)セット", systemImage: "repeat")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // totalCalories は残す
    private var totalCalories: Double {
        workoutSets.reduce(0) { $0 + $1.caloriesBurned }
    }
}
