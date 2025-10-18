//
//  AllFoodsListView.swift - 完全修正版
//  FitnessTracker
//

import SwiftUI
import CoreData

// MARK: - 全食事リスト画面
struct AllFoodsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let selectedDate: Date
    let foods: [FoodRecord]
    
    @State private var selectedFood: FoodRecord?
    @State private var showingFoodDetail = false
    
    // 食事タイプ別にグループ化
    private var groupedFoods: [(String, [FoodRecord])] {
        let mealTypes = ["朝食", "昼食", "夕食", "間食"]
        return mealTypes.compactMap { mealType in
            let filtered = foods.filter { $0.mealType == mealType }
            return filtered.isEmpty ? nil : (mealType, filtered)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if foods.isEmpty {
                    emptyStateView
                } else {
                    ForEach(groupedFoods, id: \.0) { mealType, mealFoods in
                        Section(header: mealTypeHeader(mealType)) {
                            ForEach(mealFoods, id: \.id) { food in
                                Button(action: {
                                    handleFoodTap(food)
                                }) {
                                    FoodListRow(food: food)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .onDelete { offsets in
                                deleteFood(offsets: offsets, from: mealFoods)
                            }
                        }
                    }
                    
                    totalNutritionSection
                }
            }
            .navigationTitle(dateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
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
            
            Text("まだ食事が記録されていません")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private func mealTypeHeader(_ mealType: String) -> some View {
        HStack {
            Text(mealType)
                .font(.headline)
            
            Spacer()
            
            let mealFoods = foods.filter { $0.mealType == mealType }
            Text("\(Int(mealFoods.reduce(0) { $0 + $1.actualCalories }))kcal")
                .font(.subheadline)
                .foregroundColor(.orange)
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
    
    // MARK: - Functions

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)の食事"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }

    private func handleFoodTap(_ food: FoodRecord) {
        print("=== 食材タップ ===")
        print("食材名: \(food.foodName)")
        print("オブジェクトID: \(food.objectID)")
        
        // CoreDataから最新の状態を取得
        do {
            if let refreshedFood = try viewContext.existingObject(with: food.objectID) as? FoodRecord {
                selectedFood = refreshedFood
                showingFoodDetail = true
                print("✅ リフレッシュ成功")
            } else {
                print("❌ オブジェクトが見つかりません")
            }
        } catch {
            print("❌ リフレッシュエラー: \(error.localizedDescription)")
            // エラーでも一応試す
            selectedFood = food
            showingFoodDetail = true
        }
    }

    private func deleteFood(offsets: IndexSet, from mealFoods: [FoodRecord]) {
        print("=== 削除開始 ===")
        
        for index in offsets {
            let foodToDelete = mealFoods[index]
            print("削除する食材: \(foodToDelete.foodName)")
            
            // リレーションシップを解除
            foodToDelete.foodMaster = nil
            viewContext.delete(foodToDelete)
        }
        
        do {
            try viewContext.save()
            print("✅ 削除成功")
        } catch {
            print("❌ 削除エラー: \(error.localizedDescription)")
            viewContext.rollback()
        }
    }
}

// MARK: - 食事行コンポーネント
struct FoodListRow: View {
    let food: FoodRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // 食材アイコン
            if let photoData = food.photo,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "fork.knife")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            
            // 食材情報
            VStack(alignment: .leading, spacing: 2) {
                Text(food.foodName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(food.servingMultiplier, specifier: "%.1f")人前")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // カロリー
            Text("\(Int(food.actualCalories))kcal")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    AllFoodsListView(
        selectedDate: Date(),
        foods: []
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
