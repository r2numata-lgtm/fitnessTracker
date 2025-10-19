//
//  CalorieBalanceCard.swift
//  FitnessTracker
//  Views/Home/CalorieBalanceCard.swift
//
//  Updated on 2025/10/19.
//

import SwiftUI
import CoreData

// MARK: - カロリー収支カード
struct CalorieBalanceCard: View {
    let selectedDate: Date
    let dailyCalories: DailyCalories?
    let todayWorkouts: [WorkoutEntry]
    let todayFoods: [FoodRecord]
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var latestBodyComposition: BodyComposition?
    @State private var showingAddBodyComposition = false
    
    private var totalIntake: Double {
        todayFoods.reduce(0) { $0 + $1.actualCalories }
    }
    
    private var workoutCalories: Double {
        todayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    // 基礎代謝
    private var basalMetabolicRate: Double {
        latestBodyComposition?.basalMetabolicRate ?? 0
    }
    
    // 活動代謝（歩数から計算）
    private var activityCalories: Double {
        guard let composition = latestBodyComposition else { return 0 }
        let steps = Double(healthKitManager.dailySteps)
        let weight = composition.weight
        return steps * weight * 0.04 / 1000
    }
    
    // 総消費カロリー = 基礎代謝 + 活動代謝 + 筋トレ消費
    private var totalBurned: Double {
        basalMetabolicRate + activityCalories + workoutCalories
    }
    
    private var netCalories: Double {
        totalIntake - totalBurned
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // 体組成データが無い場合の警告
            if latestBodyComposition == nil {
                bodyCompositionPromptView
            } else {
                calorieBalanceView
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .onAppear {
            fetchLatestBodyComposition()
        }
        .sheet(isPresented: $showingAddBodyComposition) {
            AddBodyCompositionView(selectedDate: selectedDate)
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    // MARK: - 体組成データ未登録時のビュー
    private var bodyCompositionPromptView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("体組成データが未登録です")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text("基礎代謝を計算できないため、消費カロリーが正確に表示されません")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingAddBodyComposition = true
            }) {
                Text("体組成を登録")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - カロリー収支ビュー
    private var calorieBalanceView: some View {
        VStack(spacing: 15) {
            Text("今日のカロリー収支")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(Int(netCalories))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(netCalories > 0 ? .red : .green)
            
            Text("kcal")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Divider()
            
            // 摂取・消費の詳細
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("摂取カロリー")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(totalIntake))kcal")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("総消費カロリー")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(totalBurned))kcal")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
                
                Divider()
                
                // 消費カロリーの内訳
                VStack(spacing: 8) {
                    HStack {
                        Text("基礎代謝")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(basalMetabolicRate))kcal")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.caption2)
                            Text("活動代謝")
                                .font(.caption)
                            Text("(\(healthKitManager.dailySteps)歩)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        Text("\(Int(activityCalories))kcal")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    
                    if workoutCalories > 0 {
                        HStack {
                            Text("筋トレ消費")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(workoutCalories))kcal")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.purple)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - 最新の体組成データを取得
    private func fetchLatestBodyComposition() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<BodyComposition> = BodyComposition.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                        startOfDay as NSDate,
                                        endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            
            if let todayComposition = results.first {
                // 選択日のデータが見つかった
                latestBodyComposition = todayComposition
                print("✅ \(formatSelectedDate())の体組成データを取得: BMR=\(Int(basalMetabolicRate))kcal")
            } else {
                // 選択日のデータがない場合は、最新のデータを取得
                let latestRequest: NSFetchRequest<BodyComposition> = BodyComposition.fetchRequest()
                latestRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)]
                latestRequest.fetchLimit = 1
                
                let latestResults = try viewContext.fetch(latestRequest)
                latestBodyComposition = latestResults.first
                
                if latestResults.first != nil {
                    print("⚠️ \(formatSelectedDate())のデータなし。最新データを使用: BMR=\(Int(basalMetabolicRate))kcal")
                } else {
                    print("⚠️ 体組成データが登録されていません")
                }
            }
        } catch {
            print("❌ 体組成データ取得エラー: \(error)")
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }
}

#Preview {
    CalorieBalanceCard(
        selectedDate: Date(),
        dailyCalories: nil,
        todayWorkouts: [],
        todayFoods: []
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .environmentObject(HealthKitManager())
    .padding()
}
