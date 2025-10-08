//
//  HintSectionView.swift
//  FitnessTracker
//  Views/Food/AddFood/BarcodeSearch/EmptyStates/HintSectionView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - スキャンのコツ表示
struct HintSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スキャンのコツ")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HintRow(icon: "lightbulb.fill", text: "明るい場所でスキャンする")
                HintRow(icon: "camera.viewfinder", text: "バーコード全体がフレーム内に入るように")
                HintRow(icon: "hand.raised.fill", text: "手ブレしないよう安定させる")
                HintRow(icon: "magnifyingglass", text: "商品パッケージのバーコードを探す")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - ヒント行
struct HintRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HintSectionView()
        .padding()
}
