//
//  FloatingActionButton.swift
//  FitnessTracker
//  Views/Food/Components/FloatingActionButton.swift
//
//  Updated on 2025/10/19.
//

import SwiftUI

// MARK: - フローティングアクションボタン
struct FloatingActionButton: View {
    let action: () -> Void
    var color: Color = .green  // デフォルトは緑
    var icon: String = "square.and.pencil"  // デフォルトアイコン
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FloatingActionButton(action: {}, color: .green)
        FloatingActionButton(action: {}, color: .blue, icon: "plus")
        FloatingActionButton(action: {}, color: .orange)
    }
    .padding()
}
