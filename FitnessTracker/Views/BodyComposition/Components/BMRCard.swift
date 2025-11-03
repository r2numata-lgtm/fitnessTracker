//
//  BMRCard.swift
//  FitnessTracker
//  Views/BodyComposition/Components/BMRCard.swift
//

import SwiftUI

struct BMRCard: View {
    let bodyComposition: BodyComposition
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("基礎代謝・消費カロリー")
                .font(.headline)
            
            VStack(spacing: 12) {
                // 基礎代謝
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("基礎代謝（BMR）")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(bodyComposition.basalMetabolicRate))kcal/日")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // 活動代謝
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("活動代謝")
                                .font(.subheadline)
                            Text("(推定)")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                        
                        let activityCalories = calculateActivityCalories()
                        
                        Text("\(Int(activityCalories))kcal/日")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        // データソース表示
                        Text(activityDataSourceText)
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // 総消費カロリー
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("総消費カロリー（推定）")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        let totalCalories = bodyComposition.basalMetabolicRate + calculateActivityCalories()
                        
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
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - 活動代謝の計算
    private func calculateActivityCalories() -> Double {
        let weight = bodyComposition.weight
        let activityLevel = getUserActivityLevel()
        
        // HealthKitManagerの最適化計算を使用
        let calculatedCalories = healthKitManager.calculateOptimalActivityCalories(
            weight: weight,
            activityLevel: activityLevel
        )
        
        // 活動レベル係数を使用する場合
        if calculatedCalories == 0, let level = activityLevel {
            return CalorieCalculator.calculateActivityCaloriesFromLevel(
                bmr: bodyComposition.basalMetabolicRate,
                activityLevel: level
            )
        }
        
        return calculatedCalories
    }
    
    private var activityDataSourceText: String {
        if healthKitManager.dailyActiveCalories > 0 {
            return "📱 Apple Watch データ"
        } else if healthKitManager.dailyDistance > 0 {
            return "📍 移動距離: \(String(format: "%.2f", healthKitManager.dailyDistance))km"
        } else if healthKitManager.dailySteps > 0 {
            return "👣 歩数: \(healthKitManager.dailySteps)歩"
        } else if getUserActivityLevel() != nil {
            return "⚙️ 活動レベル係数"
        } else {
            return "⚠️ データなし"
        }
    }
    
    private func getUserActivityLevel() -> ActivityLevel? {
        if let levelString = UserDefaults.standard.string(forKey: "userActivityLevel") {
            return ActivityLevel(rawValue: levelString)
        }
        return .light  // この行を追加
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let composition = BodyComposition(context: context)
    composition.weight = 70
    composition.height = 175
    composition.basalMetabolicRate = 1650
    
    return BMRCard(bodyComposition: composition)
        .environmentObject(HealthKitManager())
        .padding()
}
