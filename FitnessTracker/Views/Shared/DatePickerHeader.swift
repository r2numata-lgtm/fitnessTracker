//
//  DatePickerHeader.swift
//  FitnessTracker
//  Views/Components/DatePickerHeader.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import SwiftUI

// MARK: - 日付選択ヘッダー（共通コンポーネント）
struct DatePickerHeader: View {
    @Binding var selectedDate: Date
    let onDateChanged: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
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
                Text(dateFormatter.string(from: selectedDate))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                    Button("Today") {
                        selectedDate = Date()
                        onDateChanged()
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
    }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            // 未来の日付には移動できない
            if newDate <= Date() || days < 0 {
                selectedDate = newDate
                onDateChanged()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DatePickerHeader(
            selectedDate: .constant(Date()),
            onDateChanged: {}
        )
        
        DatePickerHeader(
            selectedDate: .constant(Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
            onDateChanged: {}
        )
    }
    .padding()
}
