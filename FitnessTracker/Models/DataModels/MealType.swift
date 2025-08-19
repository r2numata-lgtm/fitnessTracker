//
//  MealType.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import Foundation

// MARK: - 食事カテゴリ
enum MealType: String, CaseIterable {
    case breakfast = "朝食"
    case lunch = "昼食"
    case dinner = "夕食"
    case snack = "間食"
    
    var displayName: String {
        return self.rawValue
    }
}
