//
//  FloatingActionButton.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - フローティングアクションボタン
struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}
