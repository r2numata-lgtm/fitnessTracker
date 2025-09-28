//
//  SharedProduct.swift
//  FitnessTracker
//  Models/DataModels/Food/SharedProduct.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation

// MARK: - 共有商品データ
struct SharedProduct: Identifiable, Codable {
    let id: String
    let barcode: String?
    let name: String
    let brand: String?
    let nutrition: NutritionInfo
    let category: String?
    let packageSize: String?
    let imageURL: String?
    let description: String?
    let contributorId: String
    let createdAt: Date
    let updatedAt: Date
    let verificationCount: Int
    let reportCount: Int
    let isVerified: Bool
    
    var trustScore: Double {
        let baseScore = 0.5
        let verificationBonus = min(Double(verificationCount) * 0.1, 0.4)
        let reportPenalty = min(Double(reportCount) * 0.2, 0.3)
        let verifiedBonus = isVerified ? 0.2 : 0.0
        
        return max(0.0, min(1.0, baseScore + verificationBonus - reportPenalty + verifiedBonus))
    }
    
    init(
        barcode: String? = nil,
        name: String,
        brand: String? = nil,
        nutrition: NutritionInfo,
        category: String? = nil,
        packageSize: String? = nil,
        imageURL: String? = nil,
        description: String? = nil,
        contributorId: String
    ) {
        self.id = UUID().uuidString
        self.barcode = barcode
        self.name = name
        self.brand = brand
        self.nutrition = nutrition
        self.category = category
        self.packageSize = packageSize
        self.imageURL = imageURL
        self.description = description
        self.contributorId = contributorId
        self.createdAt = Date()
        self.updatedAt = Date()
        self.verificationCount = 0
        self.reportCount = 0
        self.isVerified = false
    }
}

// MARK: - 投稿リクエスト
struct ProductSubmissionRequest: Codable {
    let product: SharedProduct
    let submissionNote: String?
    let imageData: Data?
}

// MARK: - 検証・報告アクション
struct ProductAction: Codable {
    let productId: String
    let userId: String
    let actionType: ActionType
    let note: String?
    let timestamp: Date
    
    enum ActionType: String, Codable {
        case verify = "verify"
        case report = "report"
        case update = "update"
    }
}
