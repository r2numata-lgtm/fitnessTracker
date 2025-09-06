//
//  MealDetailView.swift
//  FitnessTracker
//  Views/Food/Home/MealDetailView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 食事詳細画面
struct MealDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
