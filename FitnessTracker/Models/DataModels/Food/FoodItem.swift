//
//  FoodItem.swift
//  FitnessTracker
//  Models/DataModels/FoodItem.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation

// MARK: - 食品アイテム
struct FoodItem: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let nutrition: NutritionInfo
    let category: String?
    let barcode: String?
    let imageURL: String?
    let brand: String?
    
    init(
        name: String,
        nutrition: NutritionInfo,
        category: String? = nil,
        barcode: String? = nil,
        imageURL: String? = nil,
        brand: String? = nil
    ) {
        self.name = name
        self.nutrition = nutrition
        self.category = category
        self.barcode = barcode
        self.imageURL = imageURL
        self.brand = brand
    }
}

// MARK: - FoodItem Extensions
extension FoodItem {
    /// 指定したグラム数での食品情報を取得
    func withAmount(_ grams: Double) -> FoodItem {
        return FoodItem(
            name: name,
            nutrition: nutrition.scaled(to: grams),
            category: category,
            barcode: barcode,
            imageURL: imageURL,
            brand: brand
        )
    }
    
    /// 表示用の名前（ブランド名がある場合は含める）
    var displayName: String {
        if let brand = brand {
            return "\(brand) \(name)"
        }
        return name
    }
}

// MARK: - サンプルデータ
extension FoodItem {
    static let samples: [FoodItem] = [
        FoodItem(
            name: "白米",
            nutrition: NutritionInfo(
                calories: 356,
                protein: 6.1,
                fat: 0.9,
                carbohydrates: 77.6,
                sugar: 77.6,
                servingSize: 100,
                fiber: 0.5
            ),
            category: "穀物"
        ),
        FoodItem(
            name: "鶏胸肉（皮なし）",
            nutrition: NutritionInfo(
                calories: 191,
                protein: 23.3,
                fat: 1.9,
                carbohydrates: 0,
                sugar: 0,
                servingSize: 100
            ),
            category: "肉類"
        ),
        FoodItem(
            name: "卵",
            nutrition: NutritionInfo(
                calories: 151,
                protein: 12.3,
                fat: 10.3,
                carbohydrates: 0.3,
                sugar: 0.3,
                servingSize: 100
            ),
            category: "卵・乳製品"
        )
    ]
}
