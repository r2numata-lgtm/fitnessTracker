//
//  SimpleFoodComponents.swift
//  FitnessTracker
//  Views/Food/Components/SimpleFoodComponents.swift
//
//  Created: 2025/11/03
//

import SwiftUI

// MARK: - シンプルな食材表示行（画像なし）
struct SimpleFoodDisplayRow: View {
    let name: String
    let calories: Double
    let servingInfo: String?
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let info = servingInfo {
                    Text(info)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("\(Int(calories))kcal")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - FoodRecordから使用
extension SimpleFoodDisplayRow {
    init(foodRecord: FoodRecord) {
        self.name = foodRecord.foodName
        self.calories = foodRecord.actualCalories
        self.servingInfo = "\(String(format: "%.1f", foodRecord.servingMultiplier))人前"
    }
}

// MARK: - 検索結果表示用（カテゴリ・ソース付き）
struct SearchResultRow: View {
    let result: FoodSearchResult
    let showCategory: Bool
    let onTap: () -> Void
    
    init(result: FoodSearchResult, showCategory: Bool = true, onTap: @escaping () -> Void) {
        self.result = result
        self.showCategory = showCategory
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 食材情報（画像なし）
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if showCategory, let category = result.category {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // カロリー
                Text("\(Int(result.nutrition.calories))kcal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
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
}

// MARK: - よく使う食材表示用
struct FavoriteFoodDisplayRow: View {
    let food: FoodItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    if let category = food.category {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text("\(Int(food.nutrition.calories))kcal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
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
}


// MARK: - FoodMaster表示用（履歴画面）
struct FoodMasterDisplayRow: View {
    let master: FoodMaster
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(master.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    if let category = master.category {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text("\(Int(master.calories))kcal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
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
}
