//
//  ActivityLevel.swift
//  FitnessTracker
//  Models/DataModels/BodyComposition/ActivityLevel.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import Foundation

// MARK: - 活動レベルの列挙型
enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary = "座りがち"
    case light = "軽度の活動"
    case moderate = "中程度の活動"
    case active = "活発"
    case veryActive = "非常に活発"
    
    var id: String { rawValue }
    
    /// TDEEを計算するための係数
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
    
    /// 説明文
    var description: String {
        switch self {
        case .sedentary: return "ほとんど運動しない"
        case .light: return "週1-3日の軽い運動"
        case .moderate: return "週3-5日の中程度の運動"
        case .active: return "週6-7日の激しい運動"
        case .veryActive: return "1日2回以上の激しい運動"
        }
    }
    
    /// CoreDataに保存する値
    var storageValue: String {
        switch self {
        case .sedentary: return "sedentary"
        case .light: return "light"
        case .moderate: return "moderate"
        case .active: return "active"
        case .veryActive: return "veryActive"
        }
    }
    
    /// CoreDataから読み込む
    static func from(storageValue: String?) -> ActivityLevel {
        guard let value = storageValue else { return .light }
        switch value {
        case "sedentary": return .sedentary
        case "light": return .light
        case "moderate": return .moderate
        case "active": return .active
        case "veryActive": return .veryActive
        default: return .light
        }
    }
}
