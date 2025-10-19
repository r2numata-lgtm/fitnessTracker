//
//  BodyCompositionManager.swift
//  FitnessTracker
//  Models/Managers/BodyCompositionManager.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import Foundation
import CoreData
import Combine

@MainActor
class BodyCompositionManager: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var latestBodyComposition: BodyComposition?
    @Published var basalMetabolicRate: Double = 0
    @Published var hasBodyCompositionData: Bool = false
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchLatestBodyComposition()
    }
    
    // MARK: - 最新の体組成データを取得
    func fetchLatestBodyComposition() {
        let request: NSFetchRequest<BodyComposition> = BodyComposition.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            latestBodyComposition = results.first
            basalMetabolicRate = results.first?.basalMetabolicRate ?? 0
            hasBodyCompositionData = results.first != nil
            
            if let latest = results.first {
                print("✅ 最新の体組成データを取得: BMR=\(Int(latest.basalMetabolicRate))kcal")
            } else {
                print("⚠️ 体組成データが登録されていません")
            }
        } catch {
            print("❌ 体組成データ取得エラー: \(error)")
        }
    }
    
    // MARK: - 総消費カロリーを計算
    func calculateTotalCalories(activityCalories: Double) -> Double {
        return basalMetabolicRate + activityCalories
    }
    
    // MARK: - 歩数から活動代謝を計算
    func calculateActivityCalories(steps: Int) -> Double {
        guard let composition = latestBodyComposition else {
            return 0
        }
        
        // 計算式: 歩数 × 体重(kg) × 0.04 / 1000
        let stepsDouble = Double(steps)
        let weight = composition.weight
        return stepsDouble * weight * 0.04 / 1000
    }
}
