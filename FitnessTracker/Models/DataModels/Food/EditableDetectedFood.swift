//
//  EditableDetectedFood.swift
//  FitnessTracker
//  Models/DataModels/Food/EditableDetectedFood.swift
//
//  Created by 沼田蓮二朗 on 2025/09/07.
//

import Foundation

// MARK: - EditableDetectedFood (PhotoResultViewで使用)
struct EditableDetectedFood: Identifiable {
    let id = UUID()
    var name: String
    var estimatedWeight: Double
    var nutrition: NutritionInfo
    let confidence: Double
    var isIncluded: Bool
    
    var displayWeight: String {
        if estimatedWeight >= 1000 {
            return String(format: "%.1fkg", estimatedWeight / 1000)
        } else {
            return String(format: "%.0fg", estimatedWeight)
        }
    }
}
