//
//  CurrentStatsCard.swift
//  FitnessTracker
//  Views/BodyComposition/Components/CurrentStatsCard.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import SwiftUI

struct CurrentStatsCard: View {
    let bodyComposition: BodyComposition
    let selectedDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(formatDateTitle(selectedDate))
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatItem(
                    title: "身長",
                    value: "\(Int(bodyComposition.height))cm",
                    color: .blue
                )
                
                StatItem(
                    title: "体重",
                    value: String(format: "%.1fkg", bodyComposition.weight),
                    color: .green
                )
                
                if bodyComposition.bodyFatPercentage > 0 {
                    StatItem(
                        title: "体脂肪率",
                        value: String(format: "%.1f%%", bodyComposition.bodyFatPercentage),
                        color: .orange
                    )
                }
                
                StatItem(
                    title: "BMI",
                    value: String(format: "%.1f", calculateBMI(bodyComposition)),
                    color: .purple
                )
                
                if bodyComposition.muscleMass > 0 {
                    StatItem(
                        title: "筋肉量",
                        value: String(format: "%.1fkg", bodyComposition.muscleMass),
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    private func calculateBMI(_ composition: BodyComposition) -> Double {
        BodyCompositionCalculator.calculateBMI(
            weight: composition.weight,
            height: composition.height
        )
    }
    
    private func formatDateTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今日の体組成"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年M月d日の体組成"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: date)
        }
    }
}

// MARK: - 統計アイテム
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
