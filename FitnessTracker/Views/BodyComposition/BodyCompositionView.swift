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
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    @State private var selectedDate = Date()
    @State private var showingAddEntry = false
    @State private var refreshID = UUID()
    
    // 選択日の体組成データを取得
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)],
        animation: .default
    )
    private var allBodyCompositions: FetchedResults<BodyComposition>
    
    // 前の日付の変更を防ぐため
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            // 未来の日付には移動できない
            if newDate <= Date() {
                selectedDate = newDate
                refreshID = UUID()
            }
        }
    }
    
    // 選択した日付のデータを取得
    private var todayComposition: BodyComposition? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return allBodyCompositions.first { composition in
            composition.date >= startOfDay && composition.date < endOfDay
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // 日付選択ヘッダー
                    DatePickerHeader(
                        selectedDate: $selectedDate,
                        onDateChanged: {
                            refreshID = UUID()
                        }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // メインコンテンツ
                    ScrollView {
                        VStack(spacing: 20) {
                            if let composition = todayComposition {
                                // データがある場合
                                CurrentStatsCard(
                                    bodyComposition: composition,
                                    selectedDate: selectedDate
                                )
                                .id(refreshID)
                                
                                BMRCard(
                                    bodyComposition: composition
                                )
                                .id(refreshID)
                                
                                // 全履歴のグラフ
                                if allBodyCompositions.count >= 2 {
                                    WeightChartCard(bodyCompositions: Array(allBodyCompositions))
                                }
                                
                                // 全履歴リスト
                                HistoryListView(bodyCompositions: Array(allBodyCompositions))
                            } else {
                                // データが無い場合
                                emptyStateView
                            }
                            
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
                        FloatingActionButton(
                            action: {
                                showingAddEntry = true
                            },
                            color: .orange,
                            icon: "square.and.pencil"
                        )
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("体組成管理")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddEntry) {
                AddBodyCompositionView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                // 初回起動時に古いデータをマイグレーション
                migrateOldDataIfNeeded()
            }
        }
    }
    
    // MARK: - データマイグレーション
    private func migrateOldDataIfNeeded() {
        let hasRunMigrationKey = "hasRunBodyCompositionMigration_v1"
        
        if !UserDefaults.standard.bool(forKey: hasRunMigrationKey) {
            print("🔄 体組成データのマイグレーションを開始...")
            DataMigrationHelper.migrateBodyCompositionDates(context: viewContext)
            UserDefaults.standard.set(true, forKey: hasRunMigrationKey)
            
            // マイグレーション後にデータを再読み込み
            refreshID = UUID()
        }
    }
    
    // MARK: - 日付選択ヘッダー
    private var datePickerHeader: some View {
        HStack {
            Button(action: {
                changeDate(by: -1)
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(formatDate(selectedDate))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                    Button("Today") {
                        selectedDate = Date()
                        refreshID = UUID()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Button(action: {
                changeDate(by: 1)
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
        .padding(.bottom, 8)
    }
    
    // MARK: - 空の状態
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("\(formatDate(selectedDate))の\n体組成データがありません")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if !allBodyCompositions.isEmpty {
                Text("右下の「+」ボタンから記録しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("初回の体組成データを登録して\n基礎代謝を計算しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.top, 60)
    }
    
    // MARK: - 日付フォーマット
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

#Preview {
    BodyCompositionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(HealthKitManager())
}
