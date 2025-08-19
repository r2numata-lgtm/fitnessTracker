//
//  ExerciseSet.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import Foundation

// MARK: - ExerciseSet データ構造
struct ExerciseSet {
    var weight: Double = 0
    var reps: Int = 0
    var memo: String = ""
}

// MARK: - ExerciseSet Extensions
extension ExerciseSet {
    /// セットが有効かどうかを判定
    var isValid: Bool {
        weight > 0 && reps > 0
    }
    
    /// セットの総ボリューム（重量 × 回数）を計算
    var volume: Double {
        weight * Double(reps)
    }
}

// MARK: - ExerciseSet Array Extensions
extension Array where Element == ExerciseSet {
    /// 有効なセットのみを取得
    var validSets: [ExerciseSet] {
        filter { $0.isValid }
    }
    
    /// 総ボリュームを計算
    var totalVolume: Double {
        validSets.reduce(0) { $0 + $1.volume }
    }
    
    /// 総セット数を取得
    var totalSets: Int {
        validSets.count
    }
    
    /// 総回数を計算
    var totalReps: Int {
        validSets.reduce(0) { $0 + $1.reps }
    }
}
