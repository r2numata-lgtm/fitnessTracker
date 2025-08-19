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
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(workoutSets.enumerated()), id: \.offset) { index, workout in
                    HStack {
                        Label("\(Int(workout.weight))kg", systemImage: "scalemass")
                        Label("\(workout.reps)回", systemImage: "number")
                        if let memo = workout.memo, !memo.isEmpty {
                            Text("(\(memo))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(Int(workout.caloriesBurned))kcal")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("合計: \(workoutSets.count)セット")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var totalCalories: Double {
        workoutSets.reduce(0) { $0 + $1.caloriesBurned }
    }
}
