//
//  MealDetailView.swift
//  FitnessTracker
//  Views/Food/Home/MealDetailView.swift
//

import SwiftUI
import CoreData

// MARK: - 食事詳細画面
struct MealDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let mealType: String
    let selectedDate: Date
    let foods: [FoodRecord]  // FoodEntry → FoodRecord
    
    var body: some View {
        NavigationView {
            List {
                if foods.isEmpty {
                    emptyStateView
                } else {
                    foodListSection
                    nutritionSummarySection
                }
            }
            .navigationTitle(mealType)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
    }
    
    // MARK: - View Components
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("まだ食事が記録されていません")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private var foodListSection: some View {
        Section("食事内容") {
            ForEach(foods, id: \.id) { food in
                FoodRecordDetailRow(food: food)
            }
            .onDelete(perform: deleteFood)
        }
    }
    
    private var nutritionSummarySection: some View {
        Section("合計栄養素") {
            NutritionSummaryRow(
                label: "カロリー",
                value: foods.reduce(0) { $0 + $1.actualCalories },
                unit: "kcal",
                color: .orange
            )
            
            NutritionSummaryRow(
                label: "たんぱく質",
                value: foods.reduce(0) { $0 + $1.actualProtein },
                unit: "g",
                color: .red
            )
            
            NutritionSummaryRow(
                label: "脂質",
                value: foods.reduce(0) { $0 + $1.actualFat },
                unit: "g",
                color: .orange
            )
            
            NutritionSummaryRow(
                label: "炭水化物",
                value: foods.reduce(0) { $0 + $1.actualCarbohydrates },
                unit: "g",
                color: .blue
            )
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("閉じる") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // MARK: - Functions
    
    private func deleteFood(offsets: IndexSet) {
        withAnimation {
            offsets.map { foods[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("削除エラー: \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct FoodRecordDetailRow: View {
    let food: FoodRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // 食材アイコン
            if let photoData = food.photo,
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
                    
                    Image(systemName: "fork.knife")
                        .foregroundColor(.secondary)
                }
            }
            
            // 食材情報
            VStack(alignment: .leading, spacing: 4) {
                Text(food.foodName)
                    .font(.headline)
                
                Text("\(food.servingMultiplier, specifier: "%.1f")人前")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // カロリー
            Text("\(Int(food.actualCalories))kcal")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 4)
    }
}

struct NutritionSummaryRow: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(Int(value))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MealDetailView(
        mealType: "昼食",
        selectedDate: Date(),
        foods: []
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
