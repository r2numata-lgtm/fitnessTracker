//
//  Gender.swift
//  FitnessTracker
//  Models/DataModels/BodyComposition/Gender.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import Foundation

// MARK: - 性別の列挙型
enum Gender: String, CaseIterable, Identifiable {
    case male = "男性"
    case female = "女性"
    
    var id: String { rawValue }
    
    /// CoreDataに保存する値
    var storageValue: String {
        switch self {
        case .male: return "male"
        case .female: return "female"
        }
    }
    
    /// CoreDataから読み込む
    static func from(storageValue: String?) -> Gender {
        guard let value = storageValue else { return .male }
        switch value {
        case "male": return .male
        case "female": return .female
        default: return .male
        }
    }
}
