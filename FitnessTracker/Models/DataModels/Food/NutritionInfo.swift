//
//  NutritionInfo.swift
//  FitnessTracker
//  Models/DataModels/NutritionInfo.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation

// MARK: - 栄養情報
struct NutritionInfo: Codable, Equatable {
    let calories: Double            // kcal
    let protein: Double             // g (たんぱく質)
    let fat: Double                 // g (脂質)
    let carbohydrates: Double       // g (炭水化物)
    let sugar: Double               // g (糖質)
    let servingSize: Double         // g (1食分のグラム数)
    
    // オプション項目
    let fiber: Double?              // g (食物繊維)
    let sodium: Double?             // mg (ナトリウム)
    let calcium: Double?            // mg (カルシウム)
    let iron: Double?               // mg (鉄分)
    
    init(
        calories: Double,
        protein: Double,
        fat: Double,
        carbohydrates: Double,
        sugar: Double,
        servingSize: Double = 100.0,
        fiber: Double? = nil,
        sodium: Double? = nil,
        calcium: Double? = nil,
        iron: Double? = nil
    ) {
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbohydrates = carbohydrates
        self.sugar = sugar
        self.servingSize = servingSize
        self.fiber = fiber
        self.sodium = sodium
        self.calcium = calcium
        self.iron = iron
    }
}

// MARK: - NutritionInfo Extensions
extension NutritionInfo {
    /// 指定したグラム数での栄養素を計算
    func scaled(to grams: Double) -> NutritionInfo {
        let ratio = grams / servingSize
        return NutritionInfo(
            calories: calories * ratio,
            protein: protein * ratio,
            fat: fat * ratio,
            carbohydrates: carbohydrates * ratio,
            sugar: sugar * ratio,
            servingSize: grams,
            fiber: fiber.map { $0 * ratio },
            sodium: sodium.map { $0 * ratio },
            calcium: calcium.map { $0 * ratio },
            iron: iron.map { $0 * ratio }
        )
    }
    
    /// 栄養素の合計（複数の食品を足し合わせる）
    static func + (lhs: NutritionInfo, rhs: NutritionInfo) -> NutritionInfo {
        return NutritionInfo(
            calories: lhs.calories + rhs.calories,
            protein: lhs.protein + rhs.protein,
            fat: lhs.fat + rhs.fat,
            carbohydrates: lhs.carbohydrates + rhs.carbohydrates,
            sugar: lhs.sugar + rhs.sugar,
            servingSize: lhs.servingSize + rhs.servingSize,
            fiber: addOptional(lhs.fiber, rhs.fiber),
            sodium: addOptional(lhs.sodium, rhs.sodium),
            calcium: addOptional(lhs.calcium, rhs.calcium),
            iron: addOptional(lhs.iron, rhs.iron)
        )
    }
    
    /// 空の栄養情報（初期値用）
    static var empty: NutritionInfo {
        return NutritionInfo(
            calories: 0,
            protein: 0,
            fat: 0,
            carbohydrates: 0,
            sugar: 0,
            servingSize: 0
        )
    }
}

// MARK: - Helper Functions
private func addOptional(_ lhs: Double?, _ rhs: Double?) -> Double? {
    switch (lhs, rhs) {
    case (let l?, let r?):
        return l + r
    case (let l?, nil):
        return l
    case (nil, let r?):
        return r
    case (nil, nil):
        return nil
    }
}
