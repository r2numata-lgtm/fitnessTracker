//
//  HistoryDateSection.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/Components/HistoryDateSection.swift
//

import SwiftUI

// MARK: - 日付別セクション
struct HistoryDateSection: View {
    let dateKey: String
    let entries: [FoodEntry]
    let onEntryTapped: (FoodEntry) -> Void
    
    private var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateKey) else {
            return dateKey
        }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今日"
        } else if calendar.isDateInYesterday(date) {
            return "昨日"
        } else {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "M月d日(E)"
            displayFormatter.locale = Locale(identifier: "ja_JP")
            return displayFormatter.string(from: date)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 日付ヘッダー
            HStack {
                Text(displayDate)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(entries.count)品目")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 食材リスト
            VStack(spacing: 8) {
                ForEach(entries, id: \.self) { entry in
                    HistoryEntryRow(entry: entry) {
                        onEntryTapped(entry)
                    }
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleEntry = FoodEntry(context: context)
    sampleEntry.foodName = "鶏胸肉"
    sampleEntry.calories = 191
    sampleEntry.date = Date()
    
    return HistoryDateSection(
        dateKey: "2025-09-06",
        entries: [sampleEntry],
        onEntryTapped: { _ in }
    )
    .padding()
}
