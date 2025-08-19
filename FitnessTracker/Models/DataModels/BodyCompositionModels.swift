//
//  BodyCompositionModels.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import Foundation

// MARK: - 性別
enum Gender: String, CaseIterable {
    case male = "男性"
    case female = "女性"
}

// MARK: - 活動レベル
enum ActivityLevel: CaseIterable {
    case sedentary
    case light
    case moderate
    case active
    case veryActive
    
    var displayName: String {
        switch self {
        case .sedentary: return "座り仕事中心"
        case .light: return "軽い運動"
        case .moderate: return "適度な運動"
        case .active: return "活発"
        case .veryActive: return "非常に活発"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}
