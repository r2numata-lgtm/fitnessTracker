//
//  DayCell.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import SwiftUI

// MARK: - 日付セルコンポーネント
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            Text(dayNumber)
                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                .foregroundColor(foregroundColor)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary.opacity(0.5)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else {
            return .clear
        }
    }
}
