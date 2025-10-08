//
//  ProductSummaryCard.swift
//  FitnessTracker
//  Views/Food/AddFood/BarcodeSearch/Components/ProductSummaryCard.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - 商品サマリーカード
struct ProductSummaryCard: View {
    let product: BarcodeProduct
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                productInfo
                
                actionHint
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Subviews
    
    private var productInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let brand = product.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            calorieInfo
        }
    }
    
    private var calorieInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("\(Int(product.nutrition.calories))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text("kcal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var actionHint: some View {
        HStack {
            Text("タップして詳細を確認")
                .font(.caption)
                .foregroundColor(.blue)
            
            Spacer()
            
            if let packageSize = product.packageSize {
                Text(packageSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ProductSummaryCard(
        product: BarcodeProduct(
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
            category: "おにぎり・弁当",
            packageSize: "110g"
        ),
        onTap: { print("タップ") }
    )
    .padding()
}
