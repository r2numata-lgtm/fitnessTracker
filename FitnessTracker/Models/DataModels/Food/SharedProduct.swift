//
//  SharedProduct.swift
//  FitnessTracker
//  Models/DataModels/Food/SharedProduct.swift
//

import Foundation
import FirebaseFirestore

// MARK: - 共有商品データ
struct SharedProduct: Identifiable, Codable {
    let id: String  // 非オプショナルに戻す
    let barcode: String?
    let name: String
    let brand: String?
    let nutrition: NutritionInfo
    let category: String?
    let packageSize: String?
    let imageURL: String?
    let description: String?
    let contributorId: String
    let createdAt: Date?
    let updatedAt: Date?
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
    
    // カスタムデコーダー
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // idがnilの場合はUUIDを生成
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.barcode = try container.decodeIfPresent(String.self, forKey: .barcode)
        self.name = try container.decode(String.self, forKey: .name)
        self.brand = try container.decodeIfPresent(String.self, forKey: .brand)
        self.nutrition = try container.decode(NutritionInfo.self, forKey: .nutrition)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.packageSize = try container.decodeIfPresent(String.self, forKey: .packageSize)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.contributorId = try container.decode(String.self, forKey: .contributorId)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.verificationCount = try container.decodeIfPresent(Int.self, forKey: .verificationCount) ?? 0
        self.reportCount = try container.decodeIfPresent(Int.self, forKey: .reportCount) ?? 0
        self.isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case id, barcode, name, brand, nutrition, category
        case packageSize, imageURL, description, contributorId
        case createdAt, updatedAt, verificationCount, reportCount, isVerified
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
        contributorId: String,
        verificationCount: Int = 0
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
        self.verificationCount = verificationCount
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
