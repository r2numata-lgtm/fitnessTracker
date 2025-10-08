//
//  EmptyFavoritesView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/EmptyStates/EmptyFavoritesView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - よく使う食材が空の状態
struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("まだよく使う食材がありません")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("食材を検索して保存すると\nここに表示されます")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    EmptyFavoritesView()
}
