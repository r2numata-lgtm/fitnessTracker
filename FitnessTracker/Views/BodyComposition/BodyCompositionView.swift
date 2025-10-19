//
//  BodyCompositionView.swift
//  FitnessTracker
//  Views/BodyComposition/BodyCompositionView.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import SwiftUI
import CoreData

struct BodyCompositionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddEntry = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)],
        animation: .default
    )
    private var bodyCompositions: FetchedResults<BodyComposition>
    
    var latestEntry: BodyComposition? {
        bodyCompositions.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if latestEntry != nil {
                        // 現在の体組成表示
                        CurrentStatsCard(bodyComposition: latestEntry)
                        
                        // 基礎代謝表示
                        BMRCard(bodyComposition: latestEntry)
                        
                        // 体重推移グラフ
                        if bodyCompositions.count >= 2 {
                            WeightChartCard(bodyCompositions: Array(bodyCompositions))
                        }
                        
                        // 履歴リスト
                        HistoryListView(bodyCompositions: Array(bodyCompositions))
                    } else {
                        // データが無い場合
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("体組成管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEntry = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddBodyCompositionView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    // MARK: - 空の状態
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("体組成データがありません")
                .font(.headline)
            
            Text("右上の「+」ボタンから\n体組成データを登録しましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingAddEntry = true
            }) {
                Label("体組成を記録", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    BodyCompositionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
