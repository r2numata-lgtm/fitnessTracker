//
//  CurrentStatsCard.swift
//  FitnessTracker
//  Views/BodyComposition/Components/CurrentStatsCard.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import SwiftUI

struct CurrentStatsCard: View {
    let bodyComposition: BodyComposition?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("現在の体組成")
                .font(.headline)
            
            if let composition = bodyComposition {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    StatItem(
                        title: "身長",
                        value: "\(Int(composition.height))cm",
                        color: .blue
                    )
                    
                    StatItem(
                        title: "体重",
                        value: String(format: "%.1fkg", composition.weight),
                        color: .green
                    )
                    
                    if composition.bodyFatPercentage > 0 {
                        StatItem(
                            title: "体脂肪率",
                            value: String(format: "%.1f%%", composition.bodyFatPercentage),
                            color: .orange
                        )
                    }
                    
                    StatItem(
                        title: "BMI",
                        value: String(format: "%.1f", calculateBMI(composition)),
                        color: .purple
                    )
                    
                    if composition.muscleMass > 0 {
                        StatItem(
                            title: "筋肉量",
                            value: String(format: "%.1fkg", composition.muscleMass),
                            color: .red
                        )
                    }
                }
                
                Text("最終更新: \(composition.date, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
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
