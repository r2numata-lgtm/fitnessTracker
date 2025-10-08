//
//  HistoryEntryRow.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/Components/HistoryEntryRow.swift
//

import SwiftUI

// MARK: - 履歴エントリ行
struct HistoryEntryRow: View {
    let entry: FoodEntry
    let onTap: () -> Void
    
    // ベース（1人前=100g）の栄養情報を計算
    private var baseNutrition: NutritionInfo {
        // 実際に記録された分量から1人前（100g）の栄養情報を逆算
        let baseServingSize = 100.0
        let ratio = baseServingSize / entry.servingSize
        
        return NutritionInfo(
            calories: entry.calories * ratio,
            protein: entry.protein * ratio,
            fat: entry.fat * ratio,
            carbohydrates: entry.carbohydrates * ratio,
            sugar: entry.sugar * ratio,
            servingSize: baseServingSize,
            fiber: entry.fiber > 0 ? entry.fiber * ratio : nil,
            sodium: entry.sodium > 0 ? entry.sodium * ratio : nil
        )
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 食材アイコン
                foodIcon
                
                // 食材情報
                foodInfo
                
                Spacer()
                
                // カロリー表示（ベースの1人前）
                calorieInfo
                
                // 矢印
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
            if let photoData = entry.photo,
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
                    
                    Text(entry.foodName?.prefix(1).uppercased() ?? "?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var foodInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.foodName ?? "不明な食材")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                if let mealType = entry.mealType {
                    mealTypeTag(mealType)
                }
                
                // ベースの1人前を表示
                Text("1人前 (100g)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func mealTypeTag(_ mealType: String) -> some View {
        Text(mealType)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(mealTypeColor(mealType).opacity(0.2))
            .foregroundColor(mealTypeColor(mealType))
            .cornerRadius(4)
    }
    
    private var calorieInfo: some View {
        VStack(alignment: .trailing, spacing: 2) {
            // ベースの1人前のカロリー
            Text("\(Int(baseNutrition.calories))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Text("kcal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helpers
    
    private func mealTypeColor(_ mealType: String) -> Color {
        switch mealType {
        case "朝食": return .orange
        case "昼食": return .green
        case "夕食": return .blue
        case "間食": return .purple
        default: return .gray
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // 3人前（300g）で記録された食材
    let sampleEntry = FoodEntry(context: context)
    sampleEntry.foodName = "白米"
    sampleEntry.calories = 756  // 3人前のカロリー
    sampleEntry.protein = 10.5  // 3人前
    sampleEntry.fat = 2.7       // 3人前
    sampleEntry.carbohydrates = 166.8  // 3人前
    sampleEntry.sugar = 166.8
    sampleEntry.servingSize = 300  // 3人前（300g）
    sampleEntry.mealType = "昼食"
    sampleEntry.date = Date()
    
    return VStack {
        Text("実際の記録: 白米 3人前 (300g) - 756kcal")
            .font(.caption)
            .foregroundColor(.red)
        
        Text("↓ 履歴表示（1人前に正規化）")
            .font(.caption)
            .foregroundColor(.blue)
        
        HistoryEntryRow(entry: sampleEntry) {
            print("タップ")
        }
        .padding()
        
        Text("表示: 白米 1人前 (100g) - 252kcal")
            .font(.caption)
            .foregroundColor(.green)
    }
}
