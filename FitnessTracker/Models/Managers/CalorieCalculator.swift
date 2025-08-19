//
//  CalorieCalculator.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import Foundation

// MARK: - カロリー計算ヘルパークラス
class CalorieCalculator {
    
    // MARK: - 基礎代謝計算（Harris-Benedict式）
    static func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        switch gender {
        case .male:
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case .female:
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    // MARK: - 筋トレ消費カロリー計算
    static func calculateWorkoutCalories(exerciseName: String, weight: Double, sets: Int, reps: Int) -> Double {
        let metValue = getMetValue(for: exerciseName)
        let estimatedDurationHours = Double(sets * reps) / 60.0 // 1分あたり1回と仮定
        
        return metValue * weight * estimatedDurationHours
    }
    
    // MARK: - 筋トレセット配列からカロリー計算
    static func calculateWorkoutCalories(exerciseName: String, sets: [ExerciseSet], bodyWeight: Double = 70.0) -> Double {
        let metValue = getMetValue(for: exerciseName)
        let totalReps = sets.totalReps
        let estimatedDurationHours = Double(totalReps) / 60.0
        
        return metValue * bodyWeight * estimatedDurationHours
    }
    
    // MARK: - 歩数消費カロリー計算
    static func calculateStepsCalories(steps: Int, weight: Double) -> Double {
        return Double(steps) * weight * 0.04
    }
    
    // MARK: - BMI計算
    static func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    // MARK: - 理想体重計算
    static func calculateIdealWeight(height: Double) -> Double {
        let heightInMeters = height / 100.0
        return 22.0 * heightInMeters * heightInMeters // BMI 22を基準
    }
    
    // MARK: - 活動代謝計算
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }
    
    // MARK: - Private Methods
    
    private static func getMetValue(for exerciseName: String) -> Double {
        let metValues: [String: Double] = [
            "ベンチプレス": 6.0,
            "インクラインベンチプレス": 6.5,
            "ダンベルフライ": 5.5,
            "腕立て伏せ": 3.8,
            "スクワット": 5.0,
            "レッグプレス": 4.5,
            "レッグカール": 4.0,
            "カーフレイズ": 3.5,
            "デッドリフト": 6.0,
            "懸垂": 8.0,
            "ラットプルダウン": 4.5,
            "ベントオーバーロー": 5.0,
            "ショルダープレス": 4.0,
            "サイドレイズ": 3.5,
            "リアレイズ": 3.5,
            "アップライトロー": 4.0,
            "バーベルカール": 3.5,
            "トライセプスエクステンション": 3.5,
            "ハンマーカール": 3.5,
            "ディップス": 5.0,
            "クランチ": 3.0,
            "プランク": 3.0,
            "レッグレイズ": 3.5,
            "バイシクルクランチ": 4.0,
            "ランニング": 8.0,
            "サイクリング": 7.0,
            "ウォーキング": 3.5,
            "エリプティカル": 6.0,
            "あああ": 5.0  // テスト用
        ]
        
        return metValues[exerciseName] ?? 5.0
    }
}
