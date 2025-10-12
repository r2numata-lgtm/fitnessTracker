//
//  MealDetailView.swift - 修正版
//  FitnessTracker
//

import SwiftUI
import CoreData

// MARK: - 食事タイプ別詳細画面
struct MealDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let mealType: String
    let selectedDate: Date
    let foods: [FoodRecord]
    
    @State private var selectedFood: FoodRecord?
    @State private var showingFoodDetail = false
    
    var body: some View {
        NavigationView {
            List {
                if foods.isEmpty {
                    emptyStateView
                } else {
                    ForEach(foods, id: \.id) { food in
                        Button(action: {
                            selectedFood = food
                            showingFoodDetail = true
                        }) {
                            FoodListRow(food: food)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete(perform: deleteFood)
                    
                    totalNutritionSection
                }
            }
            .navigationTitle("\(mealType)の記録")
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
            
            Text("まだ\(mealType)の記録がありません")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
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

#Preview {
    MealDetailView(
        mealType: "昼食",
        selectedDate: Date(),
        foods: []
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
