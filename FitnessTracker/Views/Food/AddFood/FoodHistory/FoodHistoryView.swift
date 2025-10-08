//
//  FoodHistoryView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/FoodHistoryView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 食事履歴から選択画面
struct FoodHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let selectedDate: Date
    
    @State private var searchText = ""
    @State private var selectedTimeRange: TimeRange = .lastWeek
    @State private var selectedFoodEntry: FoodEntry?
    @State private var groupedHistory: [String: [FoodEntry]] = [:]
    
    @FetchRequest private var foodEntries: FetchedResults<FoodEntry>
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        
        // 過去30日のデータを取得
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        
        self._foodEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)],
            predicate: NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate),
            animation: .default
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchAndFilterSection
                
                if filteredHistory.isEmpty {
                    emptyHistoryView
                } else {
                    historyListView
                }
            }
            .navigationTitle("食事履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(item: $selectedFoodEntry) { entry in
                FoodHistoryDetailView(
                    foodEntry: entry,
                    selectedDate: selectedDate
                )
                .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                groupHistoryData()
            }
            .onChange(of: selectedTimeRange) { _ in
                groupHistoryData()
            }
            .onChange(of: searchText) { _ in
                groupHistoryData()
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // 検索バー
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
            .padding(.horizontal)
            
            // 期間フィルター
            TimeRangeFilterView(selectedRange: $selectedTimeRange)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var historyListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(Array(filteredHistory.keys.sorted().reversed()), id: \.self) { dateKey in
                    if let entries = filteredHistory[dateKey], !entries.isEmpty {
                        HistoryDateSection(
                            dateKey: dateKey,
                            entries: entries,
                            onEntryTapped: { entry in
                                selectedFoodEntry = entry
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyHistoryView: some View {
        EmptyHistoryView(
            timeRange: selectedTimeRange,
            hasSearchText: !searchText.isEmpty
        )
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Text("\(totalHistoryCount)件")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredHistory: [String: [FoodEntry]] {
        guard !searchText.isEmpty else { return groupedHistory }
        
        return groupedHistory.mapValues { entries in
            entries.filter { entry in
                entry.foodName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    private var totalHistoryCount: Int {
        filteredHistory.values.reduce(0) { $0 + $1.count }
    }
    
    // MARK: - Functions
    
    private func groupHistoryData() {
        let calendar = Calendar.current
        let now = Date()
        
        // 期間フィルタリング
        let filteredEntries = foodEntries.filter { entry in
            switch selectedTimeRange {
            case .today:
                return calendar.isDateInToday(entry.date)
            case .lastWeek:
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                return entry.date >= weekAgo
            case .lastMonth:
                let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
                return entry.date >= monthAgo
            case .all:
                return true
            }
        }
        
        // 日付でグループ化
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        groupedHistory = Dictionary(grouping: filteredEntries) { entry in
            formatter.string(from: entry.date)
        }
    }
}

// MARK: - 時間範囲列挙
enum TimeRange: String, CaseIterable {
    case today = "今日"
    case lastWeek = "過去7日"
    case lastMonth = "過去30日"
    case all = "すべて"
}

#Preview {
    FoodHistoryView(selectedDate: Date())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
