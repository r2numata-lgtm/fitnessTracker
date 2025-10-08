//
//  SearchBarView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/Components/SearchBarView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - 検索バー
struct SearchBarView: View {
    @Binding var searchText: String
    let onSubmit: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("食材名を入力（例：鶏胸肉）", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit(onSubmit)
                
                if !searchText.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
}

#Preview {
    SearchBarView(
        searchText: .constant("鶏胸肉"),
        onSubmit: { print("検索") },
        onClear: { print("クリア") }
    )
}
