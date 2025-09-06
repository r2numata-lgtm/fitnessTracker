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

struct FoodHomeView_Previews: PreviewProvider {
    static var previews: some View {
        FoodHomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
