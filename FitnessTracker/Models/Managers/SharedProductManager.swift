//
//  SharedProductManager.swift
//  FitnessTracker
//  Models/Managers/SharedProductManager.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class SharedProductManager: ObservableObject {
    
    static let shared = SharedProductManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    /// 匿名認証でユーザーIDを取得
    func authenticateAnonymously() async throws -> String {
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        }
        
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }
    
    /// バーコードで共有商品を検索
    func searchByBarcode(_ barcode: String) async throws -> SharedProduct? {
        print("=== ユーザーDB検索（バーコード）===")
        print("検索バーコード: \(barcode)")
        
        let query = db.collection("shared_products")
            .whereField("barcode", isEqualTo: barcode)
            .order(by: "verificationCount", descending: true)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        guard let document = snapshot.documents.first else {
            print("バーコード検索結果: 見つからず")
            return nil
        }
        
        let product = try document.data(as: SharedProduct.self)
        print("バーコード検索結果: \(product.name)")
        return product
    }
    
    /// 商品名で共有商品を検索
    func searchByName(_ name: String) async throws -> [SharedProduct] {
        print("=== ユーザーDB検索（商品名）===")
        print("検索名: \(name)")
        
        let query = db.collection("shared_products")
            .whereField("name", isGreaterThanOrEqualTo: name)
            .whereField("name", isLessThan: name + "\u{f8ff}")
            .order(by: "verificationCount", descending: true)
            .limit(to: 20)
        
        let snapshot = try await query.getDocuments()
        
        let products = try snapshot.documents.map { document in
            try document.data(as: SharedProduct.self)
        }
        
        print("商品名検索結果: \(products.count)件")
        return products
    }
    
    /// 新しい商品を投稿
    func submitProduct(_ product: SharedProduct) async throws {
        print("=== 商品投稿 ===")
        print("投稿商品: \(product.name)")
        
        try await db.collection("shared_products")
            .document(product.id)
            .setData(from: product)
        
        print("商品投稿完了: \(product.name)")
    }
    
    /// 商品を検証（ドキュメントIDで直接）
    func verifyProduct(_ documentId: String) async throws {
        let userId = try await authenticateAnonymously()
        
        // 既に検証済みかチェック
        let existingAction = try await checkExistingAction(
            productId: documentId,
            userId: userId,
            actionType: .verify
        )
        if existingAction {
            throw SharedProductError.alreadyActioned
        }
        
        // 検証アクションを記録
        let action = ProductAction(
            productId: documentId,
            userId: userId,
            actionType: .verify,
            note: nil,
            timestamp: Date()
        )
        
        let actionData: [String: Any] = [
            "productId": action.productId,
            "userId": action.userId,
            "actionType": action.actionType.rawValue,
            "note": action.note as Any,
            "timestamp": Timestamp(date: action.timestamp)
        ]
        
        try await db.collection("product_actions")
            .document(UUID().uuidString)
            .setData(actionData)
        
        // 商品の検証カウントを増加
        try await db.collection("shared_products")
            .document(documentId)
            .updateData(["verificationCount": FieldValue.increment(Int64(1))])
        
        print("商品検証完了: \(documentId)")
    }

    /// 商品を報告（ドキュメントIDで直接）
    func reportProduct(_ documentId: String, note: String?) async throws {
        let userId = try await authenticateAnonymously()
        
        // 既に報告済みかチェック
        let existingAction = try await checkExistingAction(
            productId: documentId,
            userId: userId,
            actionType: .report
        )
        if existingAction {
            throw SharedProductError.alreadyActioned
        }
        
        // 報告アクションを記録
        let action = ProductAction(
            productId: documentId,
            userId: userId,
            actionType: .report,
            note: note,
            timestamp: Date()
        )
        
        let actionData: [String: Any] = [
            "productId": action.productId,
            "userId": action.userId,
            "actionType": action.actionType.rawValue,
            "note": action.note as Any,
            "timestamp": Timestamp(date: action.timestamp)
        ]
        
        try await db.collection("product_actions")
            .document(UUID().uuidString)
            .setData(actionData)
        
        // 商品の報告カウントを増加
        try await db.collection("shared_products")
            .document(documentId)
            .updateData(["reportCount": FieldValue.increment(Int64(1))])
        
        print("商品報告完了: \(documentId)")
    }
    
    
    // MARK: - Private Methods
    
    private func checkExistingAction(productId: String, userId: String, actionType: ProductAction.ActionType) async throws -> Bool {
        let query = db.collection("product_actions")
            .whereField("productId", isEqualTo: productId)
            .whereField("userId", isEqualTo: userId)
            .whereField("actionType", isEqualTo: actionType.rawValue)
        
        let snapshot = try await query.getDocuments()
        return !snapshot.documents.isEmpty
    }
}

// MARK: - エラー定義
enum SharedProductError: Error, LocalizedError {
    case alreadyActioned
    case authenticationFailed
    case networkError
    case productNotFound  // 追加
    
    var errorDescription: String? {
        switch self {
        case .alreadyActioned:
            return "既にアクション済みです"
        case .authenticationFailed:
            return "認証に失敗しました"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .productNotFound:
            return "商品が見つかりません"
        }
    }
}
