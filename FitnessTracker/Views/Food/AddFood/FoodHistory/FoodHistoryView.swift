//
//  FoodHistoryView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/FoodHistoryView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/07.
//

import SwiftUI
import CoreData

// MARK: - 食事履歴画面（FoodMaster使用版）
struct FoodHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let selectedDate: Date
    
    @State private var searchText = ""
    @State private var selectedFoodMaster: FoodMaster?
    @State private var foodMasters: [FoodMaster] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar
                
                if filteredMasters.isEmpty {
                    emptyView
                } else {
                    masterListView
                }
            }
            .navigationTitle("食事履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(item: $selectedFoodMaster) { master in
                FoodMasterDetailView(
                    foodMaster: master,
                    selectedDate: selectedDate
                )
                .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                loadFoodMasters()
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("食材名で検索", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
    
    private var masterListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredMasters, id: \.id) { master in
                    FoodMasterRow(master: master) {
                        selectedFoodMaster = master
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(searchText.isEmpty ? "まだ食材がありません" : "検索結果が見つかりません")
                .font(.headline)
            
            Text(searchText.isEmpty ? "食事を記録すると履歴に表示されます" : "別のキーワードで検索してください")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Text("\(foodMasters.count)種類")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredMasters: [FoodMaster] {
        if searchText.isEmpty {
            return foodMasters
        } else {
            return foodMasters.filter { master in
                master.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadFoodMasters() {
        foodMasters = FoodMasterManager.getAllFoodMasters(context: viewContext)
        print("✅ 食材マスタ読み込み: \(foodMasters.count)種類")
    }
}

#Preview {
    FoodHistoryView(selectedDate: Date())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
