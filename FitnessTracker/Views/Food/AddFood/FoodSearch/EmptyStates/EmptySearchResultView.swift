//
//  EmptySearchResultView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/EmptyStates/EmptySearchResultView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - 検索結果が空の状態
struct EmptySearchResultView: View {
    let onManualAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("検索結果が見つかりません")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("別のキーワードで検索するか\n手動で栄養情報を入力してください")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("手動で追加") {
                onManualAdd()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    EmptySearchResultView(onManualAdd: {
        print("手動追加タップ")
    })
}
