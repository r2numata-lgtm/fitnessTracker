//
//  BMRCard.swift
//  FitnessTracker
//  Views/BodyComposition/Components/BMRCard.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import SwiftUI

struct BMRCard: View {
    let bodyComposition: BodyComposition?
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("代謝情報")
                .font(.headline)
            
            if let composition = bodyComposition {
                VStack(spacing: 15) {
                    // 基礎代謝
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("基礎代謝量 (BMR)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(composition.basalMetabolicRate))kcal/日")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // 歩数と活動代謝
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("今日の歩数")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "figure.walk")
                                    .foregroundColor(.green)
                                Text("\(healthKitManager.dailySteps)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                                Text("歩")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("活動代謝")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(calculateActivityCalories(composition: composition)))kcal")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(10)
                    
                    Divider()
                    
                    // 総消費カロリー
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("総消費カロリー")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            let totalCalories = composition.basalMetabolicRate + calculateActivityCalories(composition: composition)
                            
                            Text("\(Int(totalCalories))kcal/日")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                    }
                }
                
                Text("※ 基礎代謝と活動代謝は推定値です")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("体組成データを入力してください")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - 活動代謝の計算
    private func calculateActivityCalories(composition: BodyComposition) -> Double {
        // 歩数から活動代謝を計算
        // 計算式: 歩数 × 体重(kg) × 0.04 / 1000
        let steps = Double(healthKitManager.dailySteps)
        let weight = composition.weight
        return steps * weight * 0.04 / 1000
    }
}
