//
//  BodyCompositionCalculator.swift
//  FitnessTracker
//  Models/DataModels/BodyComposition/BodyCompositionCalculator.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import Foundation

// MARK: - 体組成計算ユーティリティ
struct BodyCompositionCalculator {
    
    // MARK: - BMI計算
    /// BMIを計算
    /// - Parameters:
    ///   - weight: 体重(kg)
    ///   - height: 身長(cm)
    /// - Returns: BMI値
    static func calculateBMI(weight: Double, height: Double) -> Double {
        guard height > 0 else { return 0 }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    /// BMI判定文字列を取得
    static func getBMICategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "低体重"
        case 18.5..<25:
            return "普通体重"
        case 25..<30:
            return "肥満(1度)"
        case 30..<35:
            return "肥満(2度)"
        case 35..<40:
            return "肥満(3度)"
        default:
            return "肥満(4度)"
        }
    }
    
    // MARK: - 基礎代謝計算
    /// ハリス・ベネディクト方程式(改訂版)で基礎代謝を計算
    /// - Parameters:
    ///   - weight: 体重(kg)
    ///   - height: 身長(cm)
    ///   - age: 年齢
    ///   - gender: 性別
    /// - Returns: 基礎代謝量(kcal/日)
    static func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        switch gender {
        case .male:
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case .female:
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    /// 除脂肪体重を使った精密計算(体脂肪率がある場合)
    /// - Parameters:
    ///   - weight: 体重(kg)
    ///   - bodyFatPercentage: 体脂肪率(%)
    /// - Returns: 基礎代謝量(kcal/日)
    static func calculateBMRWithBodyFat(weight: Double, bodyFatPercentage: Double) -> Double {
        let leanBodyMass = weight * (1 - bodyFatPercentage / 100)
        return 370 + (21.6 * leanBodyMass)
    }
    
    // MARK: - TDEE計算
    /// TDEE(総消費カロリー)を計算
    /// - Parameters:
    ///   - bmr: 基礎代謝量
    ///   - activityLevel: 活動レベル
    /// - Returns: TDEE(kcal/日)
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }
    
    // MARK: - 除脂肪体重計算
    /// 除脂肪体重を計算
    /// - Parameters:
    ///   - weight: 体重(kg)
    ///   - bodyFatPercentage: 体脂肪率(%)
    /// - Returns: 除脂肪体重(kg)
    static func calculateLeanBodyMass(weight: Double, bodyFatPercentage: Double) -> Double {
        return weight * (1 - bodyFatPercentage / 100)
    }
    
    // MARK: - 体脂肪量計算
    /// 体脂肪量を計算
    /// - Parameters:
    ///   - weight: 体重(kg)
    ///   - bodyFatPercentage: 体脂肪率(%)
    /// - Returns: 体脂肪量(kg)
    static func calculateFatMass(weight: Double, bodyFatPercentage: Double) -> Double {
        return weight * (bodyFatPercentage / 100)
    }
    
    // MARK: - バリデーション
    /// 入力値が妥当かチェック
    static func isValidHeight(_ height: Double) -> Bool {
        return height >= 100 && height <= 250
    }
    
    static func isValidWeight(_ weight: Double) -> Bool {
        return weight >= 20 && weight <= 300
    }
    
    static func isValidAge(_ age: Int) -> Bool {
        return age >= 10 && age <= 120
    }
    
    static func isValidBodyFatPercentage(_ percentage: Double) -> Bool {
        return percentage >= 3 && percentage <= 60
    }
}
