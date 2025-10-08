//
//  TimeRangeFilterView.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodHistory/Components/TimeRangeFilterView.swift
//

import SwiftUI

// MARK: - 期間フィルター
struct TimeRangeFilterView: View {
    @Binding var selectedRange: TimeRange
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    FilterChip(
                        title: range.rawValue,
                        isSelected: selectedRange == range
                    ) {
                        withAnimation {
                            selectedRange = range
                        }
                    }
                }
            }
        }
    }
}

// MARK: - フィルターチップ
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

#Preview {
    TimeRangeFilterView(selectedRange: .constant(.lastWeek))
        .padding()
}
