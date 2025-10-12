//
//  AllFoodsListView.swift
//  FitnessTracker
//  Views/Food/Home/AllFoodsListView.swift
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
                                    print("=== 食事タップ ===")
                                    print("食材名: \(food.foodName)")
                                    selectedFood = food
                                    showingFoodDetail = true
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
                        .onAppear {
                            print("=== 詳細シート表示 ===")
                            print("食材名: \(food.foodName)")
                        }
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
            HStack {
                Text("カロリー")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualCalories }))")
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                Text("kcal")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("たんぱく質")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualProtein }))")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Text("g")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("脂質")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualFat }))")
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                Text("g")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("炭水化物")
                Spacer()
                Text("\(Int(foods.reduce(0) { $0 + $1.actualCarbohydrates }))")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text("g")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)の食事"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }
    
    // MARK: - Functions
    
    private func deleteFood(offsets: IndexSet, from mealFoods: [FoodRecord]) {
        for index in offsets {
            let foodToDelete = mealFoods[index]
            print("=== 食事記録を削除: \(foodToDelete.objectID) ===")
            
            // FoodRecord を削除（FoodMaster は何もしない）
            viewContext.delete(foodToDelete)
        }
        
        do {
            try viewContext.save()
            print("✅ 削除成功")
        } catch {
            print("❌ 削除エラー: \(error)")
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
        .contentShape(Rectangle())
    }
}

// MARK: - 食事詳細シート
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
                
                // 栄養情報
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
                Text("この食事記録を削除しますか？")
            }
        }
    }
    
    private func deleteFood() {
        print("=== 食事記録を削除: \(food.objectID) ===")
        
        // FoodRecord を削除（FoodMaster は何もしない）
        viewContext.delete(food)
        
        do {
            try viewContext.save()
            print("✅ 削除成功")
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("❌ 削除エラー: \(error)")
            viewContext.rollback()
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

#Preview {
    AllFoodsListView(
        selectedDate: Date(),
        foods: []
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
