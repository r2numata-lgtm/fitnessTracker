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
    case sedentary = "座りがちな生活"
    case light = "軽い活動"
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
        case .sedentary: return "デスクワーク中心、ほとんど運動しない"
        case .light: return "立ち仕事や軽い運動（週1-3回）"
        case .moderate: return "毎日1時間程度の運動"
        case .active: return "毎日1-2時間の激しい運動"
        case .veryActive: return "毎日2時間以上の激しい運動またはアスリート"
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
