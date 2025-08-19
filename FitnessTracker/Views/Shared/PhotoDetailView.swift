//
//  PhotoDetailView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import SwiftUI

// MARK: - 写真詳細表示画面
struct PhotoDetailView: View {
    let photoData: Data?
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let photoData = photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        onDismiss()
                    }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button("完了") {
                        onDismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                Spacer()
            }
        }
    }
}
