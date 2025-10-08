//
//  FoodMasterRow.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/Components/FoodMasterRow.swift
//
//  Created by 沼田蓮二朗 on 2025/09/07.
//

import SwiftUI

// MARK: - 食材マスタ行
struct FoodMasterRow: View {
    let master: FoodMaster
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                foodIcon
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(master.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("1人前 (100g)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                calorieInfo
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Subviews
    
    private var foodIcon: some View {
        Group {
            if let photoData = master.photo,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 50)
                    
                    Text(master.name.prefix(1).uppercased())
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var calorieInfo: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(Int(master.calories))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text("kcal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleMaster = FoodMaster(context: context)
    sampleMaster.id = UUID()
    sampleMaster.name = "白米"
    sampleMaster.calories = 252
    sampleMaster.protein = 3.5
    sampleMaster.fat = 0.3
    sampleMaster.carbohydrates = 55.7
    sampleMaster.sugar = 55.7
    sampleMaster.fiber = 0
    sampleMaster.sodium = 0
    sampleMaster.createdAt = Date()
    
    return FoodMasterRow(master: sampleMaster) {
        print("タップ")
    }
    .padding()
}
