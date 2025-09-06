//
//  PhotoAnalysisResult.swift
//  FitnessTracker
//  Models/DataModels/PhotoAnalysisResult.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation
import CoreGraphics

// MARK: - 写真解析結果
struct PhotoAnalysisResult: Identifiable, Codable {
    let id = UUID()
    let detectedFoods: [DetectedFood]
    let overallConfidence: Double    // 全体の信頼度 (0.0 - 1.0)
    let processingTime: TimeInterval // 処理時間（秒）
    let imageSize: CGSize           // 解析した画像のサイズ
    let analysisDate: Date          // 解析日時
    
    init(
        detectedFoods: [DetectedFood],
        overallConfidence: Double,
        processingTime: TimeInterval,
        imageSize: CGSize,
        analysisDate: Date = Date()
    ) {
        self.detectedFoods = detectedFoods
        self.overallConfidence = overallConfidence
        self.processingTime = processingTime
        self.imageSize = imageSize
        self.analysisDate = analysisDate
    }
}

// MARK: - 検出された食品
struct DetectedFood: Identifiable, Codable {
    let id = UUID()
    let name: String
    let estimatedWeight: Double     // 推定重量（グラム）
    let nutrition: NutritionInfo
    let confidence: Double          // この食品の信頼度 (0.0 - 1.0)
    let boundingBox: CGRect?        // 画像内での位置（正規化済み 0.0-1.0）
    let category: String?           // 食品カテゴリ
    
    init(
        name: String,
        estimatedWeight: Double,
        nutrition: NutritionInfo,
        confidence: Double,
        boundingBox: CGRect? = nil,
        category: String? = nil
    ) {
        self.name = name
        self.estimatedWeight = estimatedWeight
        self.nutrition = nutrition
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.category = category
    }
}

// MARK: - PhotoAnalysisResult Extensions
extension PhotoAnalysisResult {
    /// 検出された全食品の合計栄養素
    var totalNutrition: NutritionInfo {
        return detectedFoods.reduce(NutritionInfo.empty) { result, food in
            result + food.nutrition
        }
    }
    
    /// 信頼度が高い食品のみフィルタ（閾値以上）
    func highConfidenceFoods(threshold: Double = 0.7) -> [DetectedFood] {
        return detectedFoods.filter { $0.confidence >= threshold }
    }
    
    /// 検出された食品数
    var foodCount: Int {
        return detectedFoods.count
    }
    
    /// 解析の品質評価
    var qualityRating: AnalysisQuality {
        switch overallConfidence {
        case 0.9...1.0:
            return .excellent
        case 0.7..<0.9:
            return .good
        case 0.5..<0.7:
            return .fair
        default:
            return .poor
        }
    }
}

// MARK: - DetectedFood Extensions
extension DetectedFood {
    /// FoodItemに変換
    var asFoodItem: FoodItem {
        FoodItem(
            name: name,
            nutrition: nutrition,
            category: category
        )
    }
    
    /// 信頼度レベル
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.9...1.0:
            return .high
        case 0.7..<0.9:
            return .medium
        case 0.5..<0.7:
            return .low
        default:
            return .veryLow
        }
    }
    
    /// 表示用の重量文字列
    var displayWeight: String {
        if estimatedWeight >= 1000 {
            return String(format: "%.1fkg", estimatedWeight / 1000)
        } else {
            return String(format: "%.0fg", estimatedWeight)
        }
    }
}

// MARK: - 列挙型定義
enum AnalysisQuality: String, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    
    var displayName: String {
        switch self {
        case .excellent: return "非常に良い"
        case .good: return "良い"
        case .fair: return "普通"
        case .poor: return "要確認"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "orange"
        case .poor: return "red"
        }
    }
}

enum ConfidenceLevel: String, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    case veryLow = "veryLow"
    
    var displayName: String {
        switch self {
        case .high: return "高信頼度"
        case .medium: return "中信頼度"
        case .low: return "低信頼度"
        case .veryLow: return "要確認"
        }
    }
}

// MARK: - サンプルデータ
extension PhotoAnalysisResult {
    static let sample: PhotoAnalysisResult = {
        let detectedFoods = [
            DetectedFood(
                name: "白米",
                estimatedWeight: 150,
                nutrition: NutritionInfo(
                    calories: 252,
                    protein: 3.5,
                    fat: 0.3,
                    carbohydrates: 55.7,
                    sugar: 55.7,
                    servingSize: 150
                ),
                confidence: 0.89,
                boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.3, height: 0.25),
                category: "穀物"
            ),
            DetectedFood(
                name: "鶏の唐揚げ",
                estimatedWeight: 80,
                nutrition: NutritionInfo(
                    calories: 232,
                    protein: 12.8,
                    fat: 14.4,
                    carbohydrates: 8.0,
                    sugar: 6.4,
                    servingSize: 80
                ),
                confidence: 0.76,
                boundingBox: CGRect(x: 0.5, y: 0.2, width: 0.25, height: 0.3),
                category: "揚げ物"
            ),
            DetectedFood(
                name: "キャベツの千切り",
                estimatedWeight: 30,
                nutrition: NutritionInfo(
                    calories: 7,
                    protein: 0.4,
                    fat: 0.1,
                    carbohydrates: 1.7,
                    sugar: 1.7,
                    servingSize: 30,
                    fiber: 0.5
                ),
                confidence: 0.72,
                boundingBox: CGRect(x: 0.1, y: 0.6, width: 0.2, height: 0.15),
                category: "野菜"
            )
        ]
        
        return PhotoAnalysisResult(
            detectedFoods: detectedFoods,
            overallConfidence: 0.82,
            processingTime: 1.8,
            imageSize: CGSize(width: 1024, height: 768)
        )
    }()
}
