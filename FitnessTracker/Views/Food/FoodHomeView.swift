//
//  FoodHomeView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

struct FoodHomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    @State private var showingAddFoodMethod = false
    @State private var showingMealDetail = false
    @State private var selectedMealType = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)],
        animation: .default)
    private var foods: FetchedResults<FoodEntry>
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 8) {
                    // 上部：シンプルな日付選択
                    HStack {
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text(selectedDate, formatter: dateFormatter)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                                Button("今日に戻る") {
                                    selectedDate = Date()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // 下部：栄養情報とリスト
                    ScrollView {
                        VStack(spacing: 12) {
                            // 摂取カロリー表示
                            CalorieIntakeCard(foods: filteredFoodsForDay)
                            
                            // 栄養素表示
                            NutritionCard(foods: filteredFoodsForDay)
                            
                            // 今日の食事カロリーまとめ
                            MealSummaryCard(
                                foods: filteredFoodsForDay,
                                onMealTapped: { mealType in
                                    selectedMealType = mealType
                                    showingMealDetail = true
                                }
                            )
                            
                            // 空きスペース（フローティングボタンのため）
                            Spacer(minLength: 80)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 右下の記録ボタン
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(action: {
                            showingAddFoodMethod = true
                        })
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("食事管理")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddFoodMethod) {
                AddFoodMethodView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingMealDetail) {
                MealDetailView(
                    mealType: selectedMealType,
                    selectedDate: selectedDate,
                    foods: filteredFoodsForMeal(selectedMealType)
                )
                .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var filteredFoodsForDay: [FoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return foods.filter { food in
            food.date >= startOfDay && food.date < endOfDay
        }
    }
    
    private func filteredFoodsForMeal(_ mealType: String) -> [FoodEntry] {
        return filteredFoodsForDay.filter { $0.mealType == mealType }
    }
}

// MARK: - 日付フォーマッター
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M月d日(E)"
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()

// MARK: - 摂取カロリーカード
struct CalorieIntakeCard: View {
    let foods: [FoodEntry]
    
    private var totalCalories: Double {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("摂取カロリー")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(Int(totalCalories))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("kcal")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 栄養素カード
struct NutritionCard: View {
    let foods: [FoodEntry]
    
    // 仮の栄養素計算（実際にはFoodEntryに栄養素データが必要）
    private var nutritionData: [(String, Double, String, Color)] {
        let totalCalories = foods.reduce(0) { $0 + $1.calories }
        // 仮の計算値（実際にはAPIや食品データベースから取得）
        return [
            ("たんぱく質", totalCalories * 0.15 / 4, "g", .red),
            ("脂質", totalCalories * 0.25 / 9, "g", .orange),
            ("炭水化物", totalCalories * 0.60 / 4, "g", .blue),
            ("糖質", totalCalories * 0.50 / 4, "g", .purple)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("栄養素")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(nutritionData, id: \.0) { nutrition in
                    NutritionItem(
                        name: nutrition.0,
                        value: nutrition.1,
                        unit: nutrition.2,
                        color: nutrition.3
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 栄養素アイテム
struct NutritionItem: View {
    let name: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(value, specifier: "%.1f")")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

// MARK: - 食事カロリーまとめカード
struct MealSummaryCard: View {
    let foods: [FoodEntry]
    let onMealTapped: (String) -> Void
    
    private var mealData: [(String, Double, Color)] {
        let mealTypes = ["朝食", "昼食", "夕食", "間食"]
        return mealTypes.map { mealType in
            let calories = foods.filter { $0.mealType == mealType }.reduce(0) { $0 + $1.calories }
            let color: Color = {
                switch mealType {
                case "朝食": return .orange
                case "昼食": return .green
                case "夕食": return .blue
                default: return .purple
                }
            }()
            return (mealType, calories, color)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("今日の食事")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(mealData, id: \.0) { meal in
                    MealSummaryItem(
                        mealType: meal.0,
                        calories: meal.1,
                        color: meal.2,
                        foods: foods.filter { $0.mealType == meal.0 }
                    ) {
                        onMealTapped(meal.0)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 食事サマリーアイテム
struct MealSummaryItem: View {
    let mealType: String
    let calories: Double
    let color: Color
    let foods: [FoodEntry]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // アイコンエリア
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: mealIcon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(color)
                    )
                
                // 食事タイプ
                Text(mealType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // カロリー
                Text("\(Int(calories))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text("kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var mealIcon: String {
        switch mealType {
        case "朝食": return "sunrise.fill"
        case "昼食": return "sun.max.fill"
        case "夕食": return "moon.fill"
        default: return "heart.fill"
        }
    }
}

// MARK: - フローティングアクションボタン
struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - 食事記録方法選択画面（仮実装）
struct AddFoodMethodView: View {
    @Environment(\.presentationMode) var presentationMode
    let selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("食事記録方法を選択")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                
                Text("STEP2で実装予定")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("記録方法選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 食事詳細画面（仮実装）
struct MealDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let mealType: String
    let selectedDate: Date
    let foods: [FoodEntry]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foods, id: \.self) { food in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(food.foodName ?? "")
                                .font(.headline)
                            
                            Text("\(Int(food.calories))kcal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let photoData = food.photo,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete(perform: deleteFood)
            }
            .navigationTitle(mealType)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteFood(offsets: IndexSet) {
        // TODO: 削除機能の実装
    }
}

struct FoodHomeView_Previews: PreviewProvider {
    static var previews: some View {
        FoodHomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
