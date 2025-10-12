//
//  FoodHomeView.swift
//  FitnessTracker
//  Views/Food/Home/FoodHomeView.swift
//

import SwiftUI
import CoreData

struct FoodHomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    @State private var showingAddFoodMethod = false
    @State private var showingMealDetail = false
    @State private var selectedMealType = ""
    @State private var showingAllFoodsList = false
    
    // データ変更を即座に反映するためのトリガー
    @State private var refreshTrigger = UUID()
    
    // Core Dataの変更を監視
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodRecord.date, ascending: false)],
        animation: .none)
    private var foods: FetchedResults<FoodRecord>
    
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
                        .disabled(Calendar.current.isDateInToday(selectedDate))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // 下部：栄養情報とリスト
                    ScrollView {
                        VStack(spacing: 12) {
                            // 摂取カロリー表示
                            CalorieIntakeCard(foods: Array(filteredFoodsForDay))
                                .id(refreshTrigger)
                                .onTapGesture {
                                    showingAllFoodsList = true
                                }
                            
                            // 栄養素表示
                            NutritionCard(
                                foods: Array(filteredFoodsForDay),
                                onShowAll: {
                                    showingAllFoodsList = true
                                }
                            )
                            .id(refreshTrigger)
                            
                            // 今日の食事カロリーまとめ
                            MealSummaryCard(
                                foods: Array(filteredFoodsForDay),
                                onMealTapped: { mealType in
                                    selectedMealType = mealType
                                    showingMealDetail = true
                                },
                                onCardTapped: {
                                    showingAllFoodsList = true
                                }
                            )
                            .id(refreshTrigger)
                            
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
            .sheet(isPresented: $showingAllFoodsList) {
                AllFoodsListView(
                    selectedDate: selectedDate,
                    foods: Array(filteredFoodsForDay)
                )
                .environment(\.managedObjectContext, viewContext)
            }
            .onChange(of: showingAddFoodMethod) { isShowing in
                if !isShowing {
                    refreshTrigger = UUID()
                }
            }
            .onChange(of: showingMealDetail) { isShowing in
                if !isShowing {
                    refreshTrigger = UUID()
                }
            }
            .onChange(of: showingAllFoodsList) { isShowing in
                if !isShowing {
                    refreshTrigger = UUID()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: viewContext)) { _ in
                refreshTrigger = UUID()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var filteredFoodsForDay: [FoodRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return foods.filter { food in
            food.date >= startOfDay && food.date < endOfDay
        }
    }
    
    private func filteredFoodsForMeal(_ mealType: String) -> [FoodRecord] {
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

#Preview {
    FoodHomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
