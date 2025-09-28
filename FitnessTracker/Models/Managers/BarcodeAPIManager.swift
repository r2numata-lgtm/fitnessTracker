//
//  BarcodeAPIManager.swift
//  FitnessTracker
//  Models/Managers/BarcodeAPIManager.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import Foundation

// MARK: - OpenFoodFacts API レスポンス構造
struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: OpenFoodFactsProduct?
}

struct OpenFoodFactsProduct: Codable {
    let productName: String?
    let brands: String?
    let quantity: String?
    let imageUrl: String?
    let nutriments: OpenFoodFactsNutriments?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case quantity
        case imageUrl = "image_url"
        case nutriments
    }
}

struct OpenFoodFactsNutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let fat100g: Double?
    let carbohydrates100g: Double?
    let sugars100g: Double?
    let fiber100g: Double?
    let sodium100g: Double?
    
    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case fat100g = "fat_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case sugars100g = "sugars_100g"
        case fiber100g = "fiber_100g"
        case sodium100g = "sodium_100g"
    }
}

// MARK: - バーコードAPI管理
class BarcodeAPIManager {
    
    static let shared = BarcodeAPIManager()
    private init() {}
    
    /// バーコードから商品情報を検索
    func searchProduct(barcode: String) async throws -> BarcodeProduct? {
        // searchProduct関数の最初に追加
        print("=== バーコード検索開始 ===")
        print("検索バーコード: \(barcode)")

        
        // OpenFoodFacts API URL
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        print("API URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            throw BarcodeAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw BarcodeAPIError.networkError
            }
            
            let apiResponse = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
            
            guard apiResponse.status == 1,
                  let openFoodProduct = apiResponse.product else {
                return nil // 商品が見つからない
            }
            
            return convertToBarcodeProduct(openFoodProduct: openFoodProduct, barcode: barcode)
            
        } catch let error as DecodingError {
            print("JSON解析エラー: \(error)")
            throw BarcodeAPIError.decodingError
        } catch {
            print("API通信エラー: \(error)")
            throw BarcodeAPIError.networkError
        }
    }
    
    // MARK: - Private Methods
    
    /// OpenFoodFactsProductをBarcodeProductに変換
    private func convertToBarcodeProduct(openFoodProduct: OpenFoodFactsProduct, barcode: String) -> BarcodeProduct {
        let nutrition = convertToNutritionInfo(nutriments: openFoodProduct.nutriments)
        
        return BarcodeProduct(
            barcode: barcode,
            name: openFoodProduct.productName ?? "不明な商品",
            brand: openFoodProduct.brands?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines),
            nutrition: nutrition,
            imageURL: openFoodProduct.imageUrl,
            category: "食品", // OpenFoodFactsから取得可能だが簡略化
            packageSize: openFoodProduct.quantity,
            description: nil
        )
    }
    
    /// OpenFoodFactsの栄養情報をNutritionInfoに変換
    private func convertToNutritionInfo(nutriments: OpenFoodFactsNutriments?) -> NutritionInfo {
        guard let nutriments = nutriments else {
            return NutritionInfo(
                calories: 0,
                protein: 0,
                fat: 0,
                carbohydrates: 0,
                sugar: 0,
                servingSize: 100
            )
        }
        
        return NutritionInfo(
            calories: nutriments.energyKcal100g ?? 0,
            protein: nutriments.proteins100g ?? 0,
            fat: nutriments.fat100g ?? 0,
            carbohydrates: nutriments.carbohydrates100g ?? 0,
            sugar: nutriments.sugars100g ?? (nutriments.carbohydrates100g ?? 0) * 0.8, // 糖質データがない場合は炭水化物の80%と仮定
            servingSize: 100, // OpenFoodFactsは100g基準
            fiber: nutriments.fiber100g,
            sodium: nutriments.sodium100g != nil ? (nutriments.sodium100g! * 1000) : nil // gをmgに変換
        )
    }
}

// MARK: - エラー定義
enum BarcodeAPIError: Error, LocalizedError {
    case invalidURL
    case networkError
    case decodingError
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .decodingError:
            return "データの解析に失敗しました"
        case .productNotFound:
            return "商品が見つかりませんでした"
        }
    }
}
