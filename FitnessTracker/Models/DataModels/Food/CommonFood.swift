//
//  CommonFood.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import Foundation

// MARK: - よく食べる食材データ
struct CommonFood {
    let name: String
    let calories: Double
}

// MARK: - 一般的な食材リスト
extension CommonFood {
    static let defaultFoods = [
        CommonFood(name: "白米(茶碗1杯)", calories: 252),
        CommonFood(name: "食パン(6枚切り1枚)", calories: 177),
        CommonFood(name: "鶏胸肉(100g)", calories: 191),
        CommonFood(name: "鶏卵(1個)", calories: 91),
        CommonFood(name: "牛乳(200ml)", calories: 134),
        CommonFood(name: "バナナ(1本)", calories: 93),
        CommonFood(name: "りんご(1個)", calories: 138),
        CommonFood(name: "納豆(1パック)", calories: 100),
        CommonFood(name: "豆腐(100g)", calories: 72),
        CommonFood(name: "サラダ(100g)", calories: 20),
        CommonFood(name: "ヨーグルト(100g)", calories: 62),
        CommonFood(name: "アボカド(1個)", calories: 262)
    ]
}
