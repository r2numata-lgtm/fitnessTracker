//
//  BarcodeProduct.swift
//  FitnessTracker
//  Models/DataModels/Food/BarcodeProduct.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation

// MARK: - バーコード商品情報
struct BarcodeProduct: Identifiable, Codable, Equatable {
    let id = UUID()
    let barcode: String
    let name: String
    let brand: String?
    let nutrition: NutritionInfo
    let imageURL: String?
    let category: String?
    let packageSize: String?      // "500ml", "200g"など
    let description: String?      // 商品説明
    
    init(
        barcode: String,
        name: String,
        brand: String? = nil,
        nutrition: NutritionInfo,
        imageURL: String? = nil,
        category: String? = nil,
        packageSize: String? = nil,
        description: String? = nil
    ) {
        self.barcode = barcode
        self.name = name
        self.brand = brand
        self.nutrition = nutrition
        self.imageURL = imageURL
        self.category = category
        self.packageSize = packageSize
        self.description = description
    }
}

// MARK: - BarcodeProduct Extensions
extension BarcodeProduct {
    /// FoodItemに変換
    var asFoodItem: FoodItem {
        FoodItem(
            name: name,
            nutrition: nutrition,
            category: category,
            barcode: barcode,
            imageURL: imageURL,
            brand: brand
        )
    }
    
    /// 表示用の商品名（ブランド + 商品名 + パッケージサイズ）
    var fullDisplayName: String {
        var components: [String] = []
        
        if let brand = brand {
            components.append(brand)
        }
        
        components.append(name)
        
        if let packageSize = packageSize {
            components.append("(\(packageSize))")
        }
        
        return components.joined(separator: " ")
    }
    
    /// 商品の栄養素密度（100gあたりのカロリー）
    var caloriesPer100g: Double {
        return nutrition.calories * (100.0 / nutrition.servingSize)
    }
}

// MARK: - サンプルデータ
extension BarcodeProduct {
    static let samples: [BarcodeProduct] = [
        BarcodeProduct(
            barcode: "4901085141434",
            name: "おにぎり 鮭",
            brand: "セブンイレブン",
            nutrition: NutritionInfo(
                calories: 180,
                protein: 4.2,
                fat: 1.8,
                carbohydrates: 35.1,
                sugar: 34.8,
                servingSize: 110,
                sodium: 520
            ),
            category: "おにぎり・弁当",
            packageSize: "110g",
            description: "北海道産の鮭を使用したおにぎり"
        ),
        BarcodeProduct(
            barcode: "4902102072448",
            name: "カップヌードル",
            brand: "日清",
            nutrition: NutritionInfo(
                calories: 351,
                protein: 10.5,
                fat: 14.6,
                carbohydrates: 44.9,
                sugar: 42.8,
                servingSize: 77,
                sodium: 1900
            ),
            category: "インスタント食品",
            packageSize: "77g",
            description: "しょうゆ味のカップ麺"
        ),
        BarcodeProduct(
            barcode: "4987386102855",
            name: "北海道牛乳",
            brand: "明治",
            nutrition: NutritionInfo(
                calories: 67,
                protein: 3.3,
                fat: 3.8,
                carbohydrates: 4.8,
                sugar: 4.8,
                servingSize: 100,
                calcium: 110
            ),
            category: "乳製品",
            packageSize: "1000ml",
            description: "北海道産の新鮮な牛乳"
        )
    ]
}
