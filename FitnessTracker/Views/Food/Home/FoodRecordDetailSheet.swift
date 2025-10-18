//
//  FoodRecordDetailSheet.swift
//  FitnessTracker
//  Views/Food/Home/FoodRecordDetailSheet.swift
//

import SwiftUI
import CoreData

// MARK: - 食事記録詳細シート
struct FoodRecordDetailSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let food: FoodRecord
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // 食材情報
                Section("食材情報") {
                    HStack {
                        Text("食材名")
                        Spacer()
                        Text(food.foodName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("分量")
                        Spacer()
                        Text("\(food.servingMultiplier, specifier: "%.1f")人前")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("食事タイプ")
                        Spacer()
                        Text(food.mealType)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 栄養情報（すべて表示）
                Section("栄養情報") {
                    NutritionDetailRow(
                        label: "カロリー",
                        value: food.actualCalories,
                        unit: "kcal",
                        color: .orange
                    )
                    
                    NutritionDetailRow(
                        label: "たんぱく質",
                        value: food.actualProtein,
                        unit: "g",
                        color: .red
                    )
                    
                    NutritionDetailRow(
                        label: "脂質",
                        value: food.actualFat,
                        unit: "g",
                        color: .orange
                    )
                    
                    NutritionDetailRow(
                        label: "炭水化物",
                        value: food.actualCarbohydrates,
                        unit: "g",
                        color: .blue
                    )
                    
                    NutritionDetailRow(
                        label: "糖質",
                        value: food.actualSugar,
                        unit: "g",
                        color: .purple
                    )
                    
                    // 食物繊維
                    if food.actualFiber > 0 {
                        NutritionDetailRow(
                            label: "食物繊維",
                            value: food.actualFiber,
                            unit: "g",
                            color: .green
                        )
                    }
                    
                    // 食塩相当量
                    if food.actualSodium > 0 {
                        NutritionDetailRow(
                            label: "食塩相当量",
                            value: food.actualSodium,
                            unit: "g",
                            color: .gray
                        )
                    }
                }
                
                // 写真
                if let photoData = food.photo,
                   let uiImage = UIImage(data: photoData) {
                    Section("写真") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                    }
                }
                
                // 削除ボタン
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("この記録を削除")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("食事詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("削除確認", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    deleteFood()
                }
            } message: {
                Text("この食事記録を削除しますか?")
            }
        }
    }
    
    // MARK: - Functions
    
    private func deleteFood() {
        print("=== 削除開始 ===")
        print("削除する食材: \(food.foodName)")
        
        // リレーションシップを解除してから削除
        food.foodMaster = nil
        viewContext.delete(food)
        
        do {
            try viewContext.save()
            print("✅ 削除成功")
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("❌ 削除エラー: \(error.localizedDescription)")
            viewContext.rollback()
        }
    }
}

// MARK: - 情報行（文字列用）
private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 栄養情報詳細行
struct NutritionDetailRow: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value, specifier: "%.1f")")
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let foodMaster = FoodMaster(context: context)
    foodMaster.id = UUID()
    foodMaster.name = "白米"
    foodMaster.calories = 252
    foodMaster.protein = 3.5
    foodMaster.fat = 0.3
    foodMaster.carbohydrates = 55.7
    foodMaster.sugar = 55.7
    foodMaster.fiber = 0.5
    foodMaster.sodium = 0
    foodMaster.createdAt = Date()
    
    let foodRecord = FoodRecord(context: context)
    foodRecord.id = UUID()
    foodRecord.date = Date()
    foodRecord.mealType = "朝食"
    foodRecord.servingMultiplier = 1.5
    foodRecord.actualCalories = 378
    foodRecord.actualProtein = 5.25
    foodRecord.actualFat = 0.45
    foodRecord.actualCarbohydrates = 83.55
    foodRecord.actualSugar = 83.55
    foodRecord.actualFiber = 0.75
    foodRecord.actualSodium = 0
    foodRecord.foodMaster = foodMaster
    
    return FoodRecordDetailSheet(food: foodRecord)
        .environment(\.managedObjectContext, context)
}
