//
//  ScanMethodButton.swift
//  FitnessTracker
//  Views/Food/AddFood/BarcodeSearch/Components/ScanMethodButton.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - スキャン方法ボタン
struct ScanMethodButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                iconView
                
                textContent
                
                Spacer()
                
                chevron
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Subviews
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 32, weight: .medium))
            .foregroundColor(color)
            .frame(width: 50)
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var chevron: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(.secondary)
    }
}

#Preview {
    VStack(spacing: 16) {
        ScanMethodButton(
            icon: "camera.viewfinder",
            title: "カメラでスキャン",
            subtitle: "バーコードをカメラで読み取り",
            color: .orange,
            action: { print("カメラ") }
        )
        
        ScanMethodButton(
            icon: "keyboard",
            title: "手動入力",
            subtitle: "バーコード番号を直接入力",
            color: .blue,
            action: { print("手動入力") }
        )
    }
    .padding()
}
