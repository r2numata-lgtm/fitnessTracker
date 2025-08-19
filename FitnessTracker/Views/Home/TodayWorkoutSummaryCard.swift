//
//  TodayWorkoutSummaryCard.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import SwiftUI

// MARK: - 今日の筋トレサマリーカード
struct TodayWorkoutSummaryCard: View {
    let workouts: [WorkoutEntry]
    
    private var groupedWorkouts: [String: [WorkoutEntry]] {
        Dictionary(grouping: workouts) { workout in
            workout.exerciseName ?? "不明な種目"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("今日の筋トレ")
                .font(.headline)
            
            ForEach(Array(groupedWorkouts.keys.sorted()), id: \.self) { exerciseName in
                if let exerciseWorkouts = groupedWorkouts[exerciseName] {
                    WorkoutSummaryRow(exerciseName: exerciseName, workouts: exerciseWorkouts)
                }
            }
            
            // 合計表示
            HStack {
                Text("合計")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(groupedWorkouts.keys.count)種目")
                    .foregroundColor(.secondary)
                Text("\(Int(workouts.reduce(0) { $0 + $1.caloriesBurned }))kcal")
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 筋トレサマリー行
struct WorkoutSummaryRow: View {
    let exerciseName: String
    let workouts: [WorkoutEntry]
    
    var body: some View {
        HStack {
            Image(systemName: "dumbbell.fill")
                .foregroundColor(.orange)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(workouts.count)セット")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(workouts.reduce(0) { $0 + $1.caloriesBurned }))kcal")
                .font(.caption)
                .foregroundColor(.orange)
                .fontWeight(.semibold)
        }
    }
}
