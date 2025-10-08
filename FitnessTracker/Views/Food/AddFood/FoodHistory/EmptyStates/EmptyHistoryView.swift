//
//  EmptyHistoryView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/EmptyStates/EmptyHistoryView.swift
//

import SwiftUI

// MARK: - 履歴が空の状態
struct EmptyHistoryView: View {
    let timeRange: TimeRange
    let hasSearchText: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(titleText)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(messageText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var iconName: String {
        hasSearchText ? "magnifyingglass" : "clock.arrow.circlepath"
    }
    
    private var titleText: String {
        if hasSearchText {
            return "検索結果が見つかりません"
        } else {
            return "\(timeRange.rawValue)の履歴がありません"
        }
    }
    
    private var messageText: String {
        if hasSearchText {
            return "別のキーワードで検索してください"
        } else {
            switch timeRange {
            case .today:
                return "今日はまだ食事を記録していません"
            case .lastWeek:
                return "過去7日間の食事履歴がありません"
            case .lastMonth:
                return "過去30日間の食事履歴がありません"
            case .all:
                return "食事を記録するとここに履歴が表示されます"
            }
        }
    }
}

#Preview {
    Group {
        EmptyHistoryView(timeRange: .lastWeek, hasSearchText: false)
        EmptyHistoryView(timeRange: .all, hasSearchText: true)
    }
}
