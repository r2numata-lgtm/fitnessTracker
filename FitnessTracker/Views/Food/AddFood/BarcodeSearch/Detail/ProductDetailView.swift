//
//  ProductDetailView.swift
//  FitnessTracker
//  Views/Food/AddFood/BarcodeSearch/Detail/ProductDetailView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 商品詳細・保存画面
struct ProductDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let product: BarcodeProduct
    let selectedDate: Date
    
    @State private var selectedMealType: MealType = .lunch
    @State private var servingAmount: Double
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingVerifyConfirm = false
    @State private var showingReportSheet = false
    
    init(product: BarcodeProduct, selectedDate: Date) {
        self.product = product
        self.selectedDate = selectedDate
        self._servingAmount = State(initialValue: product.nutrition.servingSize)
    }
    
    var body: some View {
        NavigationView {
            Form {
                productInfoSection
                mealTypeSection
                servingSizeSection
                nutritionSection
                
                if isSharedProduct {
                    qualityManagementSection
                }
            }
            .navigationTitle("商品詳細")
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
            .confirmationDialog("情報の確認", isPresented: $showingVerifyConfirm) {
                Button("この情報が正しいことを確認") {
                    verifyProduct()
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("この商品情報が正確であることを確認しますか？")
            }
            .sheet(isPresented: $showingReportSheet) {
                ReportProductView(productId: extractProductId(from: product))
            }
        }
    }
    
    // MARK: - Sections
    
    private var productInfoSection: some View {
        Section("商品情報") {
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.headline)
                
                if let brand = product.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let packageSize = product.packageSize {
                    Text("内容量: \(packageSize)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("バーコード: \(product.barcode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let description = product.description, description.contains("投稿データ") {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("ユーザー投稿データ")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
    
    private var mealTypeSection: some View {
        Section("食事の種類") {
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
                    Text(String(format: "%.0f", servingAmount))
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("g")
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $servingAmount,
                    in: 10...500,
                    step: 5
                ) {
                    Text("分量")
                }
                .accentColor(.orange)
                
                HStack {
                    Text("10g")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("500g")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var nutritionSection: some View {
        Section("栄養情報（調整後）") {
            let adjustedNutrition = product.nutrition.scaled(to: servingAmount)
            
            NutritionInfoRow(title: "カロリー", value: "\(Int(adjustedNutrition.calories))kcal", color: .orange)
            NutritionInfoRow(title: "たんぱく質", value: String(format: "%.1fg", adjustedNutrition.protein), color: .red)
            NutritionInfoRow(title: "脂質", value: String(format: "%.1fg", adjustedNutrition.fat), color: .yellow)
            NutritionInfoRow(title: "炭水化物", value: String(format: "%.1fg", adjustedNutrition.carbohydrates), color: .blue)
        }
    }
    
    private var qualityManagementSection: some View {
        Section("データ品質管理") {
            Button(action: {
                showingVerifyConfirm = true
            }) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("この情報が正しいことを確認")
                        .foregroundColor(.primary)
                }
            }
            
            Button(action: {
                showingReportSheet = true
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("間違いを報告")
                        .foregroundColor(.primary)
                }
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
                saveBarcodeProduct()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isSharedProduct: Bool {
        product.description?.contains("投稿データ") == true
    }
    
    // MARK: - Functions
    
    private func extractProductId(from product: BarcodeProduct) -> String {
        return product.barcode
    }
    
    private func verifyProduct() {
        Task {
            do {
                try await SharedProductManager.shared.verifyProduct(extractProductId(from: product))
                
                await MainActor.run {
                    alertMessage = "確認ありがとうございます！\nデータの信頼度が向上しました。"
                    showingAlert = true
                }
            } catch SharedProductError.alreadyActioned {
                await MainActor.run {
                    alertMessage = "既にこの商品を確認済みです"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "確認の送信に失敗しました"
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveBarcodeProduct() {
        do {
            try FoodSaveManager.saveBarcodeProduct(
                context: viewContext,
                product: product,
                amount: servingAmount,
                mealType: selectedMealType,
                date: selectedDate
            )
            
            // 変更: アラートを表示せず、0.5秒後に閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                presentationMode.wrappedValue.dismiss()
            }
            
        } catch {
            print("保存エラー: \(error)")
            alertMessage = "保存に失敗しました: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Helper Components

struct NutritionInfoRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    ProductDetailView(
        product: BarcodeProduct(
            barcode: "4901085141434",
            name: "おにぎり 鮭",
            brand: "セブンイレブン",
            nutrition: NutritionInfo(
                calories: 180,
                protein: 4.2,
                fat: 1.8,
                carbohydrates: 35.1,
                sugar: 34.8,
                servingSize: 110
            ),
            category: "おにぎり・弁当",
            packageSize: "110g"
        ),
        selectedDate: Date()
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
