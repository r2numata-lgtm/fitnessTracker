//
//  ScrollableCalendarView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import SwiftUI

// MARK: - スクロール可能なカレンダーコンポーネント
struct ScrollableCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var calendarDate: Date
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 12) {
            // カレンダーグリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // 曜日ヘッダー
                ForEach(weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(height: 20)
                }
                
                // 日付セル
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDate(date, inSameDayAs: Date()),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        // 右へスワイプ - 前の月
                        changeMonth(-1)
                    } else if value.translation.width < -50 {
                        // 左へスワイプ - 次の月
                        changeMonth(1)
                    }
                }
        )
        .onAppear {
            currentMonth = calendarDate
        }
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        // 日曜日を最初に移動
        return Array(symbols.suffix(from: 1)) + [symbols[0]]
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)!.start
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)!.end
        
        let startOfCalendar = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)!.start
        let endOfCalendar = calendar.date(byAdding: .day, value: 6 * 7 - 1, to: startOfCalendar)!
        
        var days: [Date?] = []
        var currentDate = startOfCalendar
        
        while currentDate <= endOfCalendar {
            if currentDate >= startOfMonth && currentDate < endOfMonth {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
    private func changeMonth(_ direction: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let newMonth = calendar.date(byAdding: .month, value: direction, to: currentMonth) {
                currentMonth = newMonth
                calendarDate = newMonth
            }
        }
    }
}
