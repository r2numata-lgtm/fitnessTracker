//
//  SharedProductManager.swift
//  FitnessTracker
//  Models/Managers/SharedProductManager.swift
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// ユーザー投稿商品の管理（Firestore専用）
class SharedProductManager: ObservableObject {
    
    static let shared = SharedProductManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - 認証
    
    /// 匿名認証でユーザーIDを取得
    func authenticateAnonymously() async throws -> String {
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        }
        
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }
    
    // MARK: - 検索
    
    /// バーコードで商品を検索
    func searchByBarcode(_ barcode: String) async throws -> SharedProduct? {
        print("=== バーコード検索 ===")
        print("検索バーコード: \(barcode)")
        
        let query = db.collection("shared_products")
            .whereField("barcode", isEqualTo: barcode)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        guard let document = snapshot.documents.first else {
            print("結果: 見つからず")
            return nil
        }
        
        let product = try document.data(as: SharedProduct.self)
        print("結果: \(product.name)")
        return product
    }
    
    /// 商品名で検索（ユーザー投稿のみ）
    func searchByName(_ name: String) async throws -> [SharedProduct] {
        print("=== ユーザー投稿検索 ===")
        print("検索名: \(name)")
        
        let normalizedTerm = normalizeForSearch(name)
        
        let query = db.collection("shared_products")
            .order(by: "verificationCount", descending: true)
            .limit(to: 10)
        
        let snapshot = try await query.getDocuments()
        
        let products = try snapshot.documents.compactMap { doc -> SharedProduct? in
            let product = try doc.data(as: SharedProduct.self)
            let productName = normalizeForSearch(product.name)
            return productName.contains(normalizedTerm) ? product : nil
        }
        
        print("結果: \(products.count)件")
        return products
    }
    
    // MARK: - 書き込み
    
    /// 新しい商品を投稿
    func submitProduct(_ product: SharedProduct) async throws {
        print("=== 商品投稿 ===")
        print("投稿商品: \(product.name)")
        
        try await db.collection("shared_products")
            .document(product.id)
            .setData(from: product)
        
        print("✅ 投稿完了")
    }
    
    /// 商品を検証（+1カウント）
    func verifyProduct(_ productId: String) async throws {
        try await db.collection("shared_products")
            .document(productId)
            .updateData([
                "verificationCount": FieldValue.increment(Int64(1)),
                "updatedAt": FieldValue.serverTimestamp()
            ])
        
        print("✅ 検証カウント +1: \(productId)")
    }
    
    /// 商品を報告
    func reportProduct(_ productId: String, reason: String) async throws {
        try await db.collection("shared_products")
            .document(productId)
            .updateData([
                "reportCount": FieldValue.increment(Int64(1)),
                "updatedAt": FieldValue.serverTimestamp()
            ])
        
        // 報告履歴を保存
        try await db.collection("product_reports").addDocument(data: [
            "productId": productId,
            "reason": reason,
            "reportedAt": FieldValue.serverTimestamp()
        ])
        
        print("✅ 商品を報告: \(productId)")
    }
    
    // MARK: - Private Methods
    
    private func normalizeForSearch(_ text: String) -> String {
        return text
            .lowercased()
            .replacingOccurrences(of: "　", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "（", with: "")
            .replacingOccurrences(of: "）", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .applyingTransform(.hiraganaToKatakana, reverse: false) ?? text
    }
}
