//
//  MealDetailView.swift - 完全修正版
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
    
    // ✅ @FetchRequestで動的取得
    @FetchRequest private var foods: FetchedResults<FoodRecord>
    
    @State private var selectedFood: FoodRecord?
    @State private var showingFoodDetail = false
    
    // ✅ initで@FetchRequestを設定
    init(mealType: String, selectedDate: Date) {
        self.mealType = mealType
        self.selectedDate = selectedDate
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        _foods = FetchRequest<FoodRecord>(
            sortDescriptors: [NSSortDescriptor(keyPath: \FoodRecord.date, ascending: false)],
            predicate: NSPredicate(
                format: "date >= %@ AND date < %@ AND mealType == %@",
                startOfDay as NSDate,
                endOfDay as NSDate,
                mealType
            )
        )
    }
    
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
            ForEach(foods) { food in
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
            // カロリー
            HStack {
                Text("カロリー")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualCalories }))")
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                Text("kcal")
                    .foregroundColor(.secondary)
            }
            
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
            let totalFiber = foods.reduce(0.0) { $0 + $1.actualFiber }
            if totalFiber > 0 {
                HStack {
                    Text("食物繊維")
                    Spacer()
                    Text("\(totalFiber, specifier: "%.1f")")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("g")
                        .foregroundColor(.secondary)
                }
            }
            
            // 食塩相当量
            let totalSodium = foods.reduce(0.0) { $0 + $1.actualSodium }
            if totalSodium > 0 {
                HStack {
                    Text("食塩相当量")
                    Spacer()
                    Text("\(totalSodium, specifier: "%.1f")")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Text("g")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalCalories: Double {
        foods.reduce(0) { $0 + $1.actualCalories }
    }
    
    private var totalProtein: Double {
        foods.reduce(0) { $0 + $1.actualProtein }
    }
    
    private var totalFat: Double {
        foods.reduce(0) { $0 + $1.actualFat }
    }
    
    private var totalCarbohydrates: Double {
        foods.reduce(0) { $0 + $1.actualCarbohydrates }
    }
    
    private var totalSugar: Double {
        foods.reduce(0) { $0 + $1.actualSugar }
    }
    
    private var totalFiber: Double {
        foods.reduce(0) { $0 + $1.actualFiber }
    }
    
    private var totalSodium: Double {
        foods.reduce(0) { $0 + $1.actualSodium }
    }
    
    // MARK: - 改善版削除処理
    private func deleteFood(offsets: IndexSet) {
        // 1. 削除対象を特定
        let foodsToDelete = offsets.map { foods[$0] }
        
        // 2. コンテキストから削除
        for food in foodsToDelete {
            // リレーションシップを手動で解除
            food.foodMaster = nil
            viewContext.delete(food)
        }
        
        // 3. 保存を試みる
        do {
            try viewContext.save()
            print("✅ 削除成功")
        } catch {
            print("❌ 削除エラー: \(error.localizedDescription)")
            viewContext.rollback()
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
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
    
    try? context.save()
    
    return MealDetailView(
        mealType: "間食",
        selectedDate: Date()
    )
    .environment(\.managedObjectContext, context)
}
