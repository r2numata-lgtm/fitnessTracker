//
//  MealDetailView.swift - 栄養素表示更新版
//  FitnessTracker
//

import SwiftUI
import CoreData

// MARK: - 食事タイプ別詳細画面
struct MealDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let mealType: String
    let selectedDate: Date
    let foods: [FoodRecord]
    
    @State private var selectedFood: FoodRecord?
    @State private var showingFoodDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if foods.isEmpty {
                    emptyStateView
                } else {
                    List {
                        foodListSection
                        totalNutritionSection
                    }
                }
            }
            .navigationTitle("\(mealType)の記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                
                if !foods.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingFoodDetail) {
                if let food = selectedFood {
                    FoodRecordDetailSheet(food: food)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("まだ\(mealType)の記録がありません")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var foodListSection: some View {
        Section {
            ForEach(foods, id: \.id) { food in
                Button {
                    selectedFood = food
                    showingFoodDetail = true
                } label: {
                    FoodListRow(food: food)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onDelete(perform: deleteFood)
        }
    }
    
    private var totalNutritionSection: some View {
        Section("合計") {
            // たんぱく質
            HStack {
                Text("たんぱく質")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualProtein }))")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Text("g")
                    .foregroundColor(.secondary)
            }
            
            // 炭水化物
            HStack {
                Text("炭水化物")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualCarbohydrates }))")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text("g")
                    .foregroundColor(.secondary)
            }
            
            // 脂質
            HStack {
                Text("脂質")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualFat }))")
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                Text("g")
                    .foregroundColor(.secondary)
            }
            
            // 糖質
            HStack {
                Text("糖質")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualSugar }))")
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Text("g")
                    .foregroundColor(.secondary)
            }
            
            // 食物繊維
            HStack {
                Text("食物繊維")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualFiber }))")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Text("g")
                    .foregroundColor(.secondary)
            }
            
            // 食塩相当量（sodiumをgで表示）
            HStack {
                Text("食塩相当量")
                Spacer()
                Text(String(format: "%.1f", foods.reduce(0) { $0 + $1.actualSodium }))
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Text("g")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // カロリーは最後に表示
            HStack {
                Text("カロリー")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualCalories }))")
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                Text("kcal")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Functions
    
    private func deleteFood(offsets: IndexSet) {
        for index in offsets {
            let food = foods[index]
            viewContext.delete(food)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("削除エラー: \(error)")
            viewContext.rollback()
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // FoodMaster作成
    let foodMaster = FoodMaster(context: context)
    foodMaster.id = UUID()
    foodMaster.name = "鶏胸肉"
    foodMaster.calories = 108
    foodMaster.protein = 23.3
    foodMaster.fat = 1.9
    foodMaster.carbohydrates = 0.0
    foodMaster.sugar = 0.0
    foodMaster.fiber = 0.0
    foodMaster.sodium = 0.04
    foodMaster.category = "肉類"
    foodMaster.createdAt = Date()
    
    // FoodRecord作成
    let foodRecord = FoodRecord(context: context)
    foodRecord.id = UUID()
    foodRecord.date = Date()
    foodRecord.mealType = "間食"
    foodRecord.servingMultiplier = 1.0
    foodRecord.actualCalories = 108
    foodRecord.actualProtein = 23.3
    foodRecord.actualFat = 1.9
    foodRecord.actualCarbohydrates = 0.0
    foodRecord.actualSugar = 0.0
    foodRecord.actualFiber = 0.0
    foodRecord.actualSodium = 0.04
    foodRecord.foodMaster = foodMaster
    
    return MealDetailView(
        mealType: "間食",
        selectedDate: Date(),
        foods: [foodRecord]
    )
    .environment(\.managedObjectContext, context)
}
