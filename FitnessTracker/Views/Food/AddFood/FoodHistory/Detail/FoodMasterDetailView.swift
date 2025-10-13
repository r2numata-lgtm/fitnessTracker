//
//  FoodMasterDetailView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/Detail/FoodMasterDetailView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/07.
//

import SwiftUI
import CoreData

// MARK: - 食材マスタ詳細画面
struct FoodMasterDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let foodMaster: FoodMaster
    let selectedDate: Date
    
    @State private var selectedMealType: MealType = .lunch
    @State private var servingMultiplier: Double = 1.0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                foodMasterInfoSection
                mealTypeSection
                servingSizeSection
                adjustedNutritionSection
            }
            .navigationTitle("分量を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("結果", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("成功") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Sections
    
    private var foodMasterInfoSection: some View {
        Section("食材情報") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(foodMaster.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    if let photoData = foodMaster.photo,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                if let category = foodMaster.category {
                    Text("カテゴリ: \(category)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("基準（1人前 = 100g）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("カロリー")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(foodMaster.calories))kcal")
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("たんぱく質")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(foodMaster.protein, specifier: "%.1f")g")
                    }
                }
                .font(.caption)
                .padding(.top, 4)
            }
        }
    }
    
    private var mealTypeSection: some View {
        Section("食事タイプ") {
            Picker("食事タイプ", selection: $selectedMealType) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Text(mealType.displayName).tag(mealType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var servingSizeSection: some View {
        Section("分量") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("分量")
                    Spacer()
                    Text(String(format: "%.1f", servingMultiplier))
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("人前")
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $servingMultiplier,
                    in: 0.1...5.0,
                    step: 0.1
                ) {
                    Text("分量")
                }
                .accentColor(.purple)
                
                HStack {
                    Text("0.1人前")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("5.0人前")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var adjustedNutritionSection: some View {
        Section("この分量での栄養情報") {
            let adjustedNutrition = foodMaster.nutritionInfo.scaled(to: 100.0 * servingMultiplier)
            
            // 基本栄養素
            NutritionDisplayRow(
                label: "カロリー",
                value: Int(adjustedNutrition.calories),
                unit: "kcal"
            )
            
            NutritionDisplayRow(
                label: "たんぱく質",
                value: Int(adjustedNutrition.protein),
                unit: "g"
            )
            
            NutritionDisplayRow(
                label: "脂質",
                value: Int(adjustedNutrition.fat),
                unit: "g"
            )
            
            NutritionDisplayRow(
                label: "炭水化物",
                value: Int(adjustedNutrition.carbohydrates),
                unit: "g"
            )
            
            NutritionDisplayRow(
                label: "糖質",
                value: Int(adjustedNutrition.sugar),
                unit: "g"
            )
            
            // 追加の栄養素（値がある場合のみ表示）
            if let fiber = adjustedNutrition.fiber, fiber > 0 {
                NutritionDisplayRow(
                    label: "食物繊維",
                    value: Int(fiber),
                    unit: "g"
                )
            }
            
            if let sodium = adjustedNutrition.sodium, sodium > 0 {
                NutritionDisplayRow(
                    label: "食塩相当量",
                    value: String(format: "%.1f", sodium),
                    unit: "g"
                )
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("保存") {
                saveFromMaster()
            }
        }
    }
    
    // MARK: - Functions
    
    private func saveFromMaster() {
        do {
            try FoodRecordManager.saveFoodRecord(
                context: viewContext,
                name: foodMaster.name,
                nutrition: foodMaster.nutritionInfo,
                servingMultiplier: servingMultiplier,
                mealType: selectedMealType,
                date: selectedDate,
                category: foodMaster.category,
                photo: foodMaster.photo
            )
            
            // Core Dataを即座に保存
            try viewContext.save()
            
            // 即座に画面を閉じる
            presentationMode.wrappedValue.dismiss()
            
        } catch {
            print("保存エラー: \(error)")
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleMaster = FoodMaster(context: context)
    sampleMaster.id = UUID()
    sampleMaster.name = "白米"
    sampleMaster.calories = 252
    sampleMaster.protein = 3.5
    sampleMaster.fat = 0.3
    sampleMaster.carbohydrates = 55.7
    sampleMaster.sugar = 55.7
    sampleMaster.fiber = 0
    sampleMaster.sodium = 0
    sampleMaster.createdAt = Date()
    
    return FoodMasterDetailView(
        foodMaster: sampleMaster,
        selectedDate: Date()
    )
    .environment(\.managedObjectContext, context)
}
