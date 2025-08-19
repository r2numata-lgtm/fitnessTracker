//
//  UserDefaults+Extensions.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import Foundation

// MARK: - UserDefaults拡張
extension UserDefaults {
    enum Keys: String {
        case userHeight = "userHeight"
        case userWeight = "userWeight"
        case userAge = "userAge"
        case userGender = "userGender"
        case dailyCalorieGoal = "dailyCalorieGoal"
        case lastSyncDate = "lastSyncDate"
    }
    
    func set(_ value: Any?, forKey key: Keys) {
        set(value, forKey: key.rawValue)
    }
    
    func object(forKey key: Keys) -> Any? {
        return object(forKey: key.rawValue)
    }
    
    func double(forKey key: Keys) -> Double {
        return double(forKey: key.rawValue)
    }
    
    func integer(forKey key: Keys) -> Int {
        return integer(forKey: key.rawValue)
    }
    
    func string(forKey key: Keys) -> String? {
        return string(forKey: key.rawValue)
    }
}
