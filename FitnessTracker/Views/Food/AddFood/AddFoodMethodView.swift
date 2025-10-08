//
//  AddFoodMethodView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 食事記録方法選択画面
struct AddFoodMethodView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let selectedDate: Date
    
    @State private var showingPhotoAnalysis = false
    @State private var showingBarcodeSearch = false
    @State private var showingFoodSearch = false
    @State private var showingFoodHistory = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー
                    VStack(spacing: 8) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("食事を記録")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("記録方法を選択してください")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // 記録方法選択カード
                    VStack(spacing: 16) {
                        // 写真から算出
                        FoodMethodCard(
                            icon: "camera.fill",
                            title: "写真から記録",
                            subtitle: "料理の写真を撮って自動で栄養素を算出",
                            color: .blue,
                            isRecommended: true
                        ) {
                            showingPhotoAnalysis = true
                        }
                        
                        // バーコードから算出
                        FoodMethodCard(
                            icon: "barcode.viewfinder",
                            title: "バーコードスキャン",
                            subtitle: "商品のバーコードを読み取って記録",
                            color: .orange
                        ) {
                            showingBarcodeSearch = true
                        }
                        
                        // 検索する
                        FoodMethodCard(
                            icon: "magnifyingglass",
                            title: "食材を検索",
                            subtitle: "食材名で検索して手動で記録",
                            color: .purple
                        ) {
                            showingFoodSearch = true
                        }
                        
                        // 履歴から選択
                        FoodMethodCard(
                            icon: "clock.arrow.circlepath",
                            title: "履歴から選択",
                            subtitle: "過去に記録した食材から選択",
                            color: .green
                        ) {
                            showingFoodHistory = true
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("食事記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPhotoAnalysis) {
                PhotoAnalysisView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingBarcodeSearch) {
                BarcodeSearchView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingFoodSearch) {
                FoodSearchView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingFoodHistory) {
                FoodHistoryView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

// 履歴選択画面（削除 - 既に別ファイルで作成済み）
// struct FoodHistoryView: View { ... }

struct AddFoodMethodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodMethodView(selectedDate: Date())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
