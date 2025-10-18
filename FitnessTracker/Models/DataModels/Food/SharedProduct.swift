//
//  SharedProduct.swift
//  FitnessTracker
//

import Foundation
import FirebaseFirestore

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
    let createdAt: Date?
    let updatedAt: Date?
    let verificationCount: Int
    let reportCount: Int
    let isVerified: Bool
    
    // 信頼スコア
    var trustScore: Double {
        let baseScore = 0.5
        let verificationBonus = min(Double(verificationCount) * 0.1, 0.4)
        let reportPenalty = min(Double(reportCount) * 0.2, 0.3)
        let verifiedBonus = isVerified ? 0.2 : 0.0
        
        return max(0.0, min(1.0, baseScore + verificationBonus - reportPenalty + verifiedBonus))
    }
    
    // カスタムデコーダー（JSON/Firestore両対応）
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
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
        
        // 日付のデコード（ISO8601文字列 or Timestamp対応）
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            self.createdAt = formatter.date(from: dateString)
        } else {
            self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        }
        
        if let dateString = try? container.decode(String.self, forKey: .updatedAt) {
            let formatter = ISO8601DateFormatter()
            self.updatedAt = formatter.date(from: dateString)
        } else {
            self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        }
        
        self.verificationCount = try container.decodeIfPresent(Int.self, forKey: .verificationCount) ?? 0
        self.reportCount = try container.decodeIfPresent(Int.self, forKey: .reportCount) ?? 0
        self.isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case id, barcode, name, brand, nutrition, category
        case packageSize, imageURL, description, contributorId
        case createdAt, updatedAt, verificationCount, reportCount, isVerified
    }
    
    // 通常のイニシャライザ
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
