//
//  SharedProductManager.swift
//  FitnessTracker
//  Models/Managers/SharedProductManager.swift
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
    
    /// 商品名で共有商品を検索（改善版）
    func searchByName(_ name: String) async throws -> [SharedProduct] {
        print("=== ユーザーDB検索（商品名）===")
        print("検索名: \(name)")
        
        let normalizedSearchTerm = normalizeForSearch(name)
        print("正規化後: \(normalizedSearchTerm)")
        
        // 1. 標準食品データベースから検索
        let standardQuery = db.collection("standard_foods")
            .order(by: "verificationCount", descending: true)
            .limit(to: 50)
        
        let standardSnapshot = try await standardQuery.getDocuments()
        var allResults: [SharedProduct] = []
        
        let standardProducts = try standardSnapshot.documents.compactMap { document -> SharedProduct? in
            let product = try document.data(as: SharedProduct.self)
            let normalizedProductName = normalizeForSearch(product.name)
            return normalizedProductName.contains(normalizedSearchTerm) ? product : nil
        }
        
        allResults.append(contentsOf: standardProducts)
        
        // 2. ユーザー投稿データベースから検索
        let userQuery = db.collection("shared_products")
            .order(by: "verificationCount", descending: true)
            .limit(to: 50)
        
        let userSnapshot = try await userQuery.getDocuments()
        let userProducts = try userSnapshot.documents.compactMap { document -> SharedProduct? in
            let product = try document.data(as: SharedProduct.self)
            let normalizedProductName = normalizeForSearch(product.name)
            return normalizedProductName.contains(normalizedSearchTerm) ? product : nil
        }
        
        allResults.append(contentsOf: userProducts)
        
        // 信頼度順にソート
        return allResults.sorted { $0.verificationCount > $1.verificationCount }
    }
    
    /// 標準食品データベースから検索
    func searchInStandardFoods(_ name: String) async throws -> [SharedProduct] {
        print("=== 標準食品DB検索 ===")
        print("検索名: \(name)")
        
        // 検索語を正規化（空白と記号を除去）
        let normalizedSearchTerm = normalizeForSearch(name)
        print("正規化後: \(normalizedSearchTerm)")
        
        // standard_foodsコレクションから検索
        let query = db.collection("standard_foods")
            .order(by: "verificationCount", descending: true)
            .limit(to: 100)
        
        let snapshot = try await query.getDocuments()
        
        let products = try snapshot.documents.compactMap { document -> SharedProduct? in
            let product = try document.data(as: SharedProduct.self)
            
            // 商品名を正規化して比較
            let normalizedProductName = normalizeForSearch(product.name)
            
            // 検索語が商品名に含まれているかチェック
            return normalizedProductName.contains(normalizedSearchTerm) ? product : nil
        }
        
        print("標準DB検索結果: \(products.count)件")
        return products
    }

    /// 検索用に文字列を正規化
    private func normalizeForSearch(_ text: String) -> String {
        return text
            .lowercased()
            .replacingOccurrences(of: "　", with: "")  // 全角スペース除去
            .replacingOccurrences(of: " ", with: "")   // 半角スペース除去
            .replacingOccurrences(of: "＜", with: "")
            .replacingOccurrences(of: "＞", with: "")
            .replacingOccurrences(of: "（", with: "")
            .replacingOccurrences(of: "）", with: "")
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .applyingTransform(.hiraganaToKatakana, reverse: false) ?? text
    }
    
    /// 新しい商品を投稿
    func submitProduct(_ product: SharedProduct) async throws {
        print("=== 商品投稿 ===")
        print("投稿商品: \(product.name)")
        
        try await db.collection("shared_products")
            .document(product.id)  // もう??は不要
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
    case productNotFound
    
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
