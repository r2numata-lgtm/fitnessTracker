//
//  ScannedBarcodeView.swift
//  FitnessTracker
//  Views/Food/AddFood/BarcodeSearch/Components/ScannedBarcodeView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - スキャン結果表示
struct ScannedBarcodeView: View {
    let barcode: String
    let isSearching: Bool
    let foundProduct: BarcodeProduct?
    let onReset: () -> Void
    let onProductTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            barcodeInfo
            
            if isSearching {
                searchingIndicator
            } else if let product = foundProduct {
                ProductSummaryCard(product: product, onTap: onProductTap)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Subviews
    
    private var barcodeInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("スキャン結果")
                    .font(.headline)
                
                Text(barcode)
                    .font(.monospaced(.body)())
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("リセット") {
                onReset()
            }
            .foregroundColor(.blue)
        }
    }
    
    private var searchingIndicator: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("OpenFoodFactsで検索中...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("インターネット接続を確認してください")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        // 検索中
        ScannedBarcodeView(
            barcode: "4901085141434",
            isSearching: true,
            foundProduct: nil,
            onReset: { print("リセット") },
            onProductTap: { print("商品タップ") }
        )
        
        // 商品発見
        ScannedBarcodeView(
            barcode: "4901085141434",
            isSearching: false,
            foundProduct: BarcodeProduct(
                barcode: "4901085141434",
                name: "おにぎり 鮭",
                brand: "セブンイレブン",
                nutrition: NutritionInfo(
                    calories: 180,
                    protein: 4.2,
                    fat: 1.8,
                    carbohydrates: 35.1,
                    sugar: 34.8,
                    servingSize: 110
                ),
                packageSize: "110g"
            ),
            onReset: { print("リセット") },
            onProductTap: { print("商品タップ") }
        )
    }
    .padding()
}
