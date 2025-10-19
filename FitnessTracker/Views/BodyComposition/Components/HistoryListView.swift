//
//  HistoryListView.swift
//  FitnessTracker
//  Views/BodyComposition/Components/HistoryListView.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import SwiftUI
import CoreData

struct HistoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let bodyCompositions: [BodyComposition]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("履歴")
                    .font(.headline)
                
                Spacer()
                
                if bodyCompositions.count > 1 {
                    Text("\(bodyCompositions.count)件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if bodyCompositions.isEmpty {
                Text("履歴がありません")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(bodyCompositions.prefix(10)) { composition in
                        HistoryRow(composition: composition, dateFormatter: dateFormatter)
                        
                        if composition != bodyCompositions.prefix(10).last {
                            Divider()
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 履歴行
struct HistoryRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    let composition: BodyComposition
    let dateFormatter: DateFormatter
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(composition.date, formatter: dateFormatter)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    Label(
                        String(format: "%.1fkg", composition.weight),
                        systemImage: "scalemass"
                    )
                    .font(.caption)
                    .foregroundColor(.green)
                    
                    if composition.bodyFatPercentage > 0 {
                        Label(
                            String(format: "%.1f%%", composition.bodyFatPercentage),
                            systemImage: "chart.pie"
                        )
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                    
                    Label(
                        "BMI \(String(format: "%.1f", calculateBMI()))",
                        systemImage: "heart.text.square"
                    )
                    .font(.caption)
                    .foregroundColor(.purple)
                }
            }
            
            Spacer()
            
            // 削除ボタン
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .alert("削除確認", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("この記録を削除しますか?")
        }
    }
    
    private func calculateBMI() -> Double {
        BodyCompositionCalculator.calculateBMI(
            weight: composition.weight,
            height: composition.height
        )
    }
    
    private func deleteEntry() {
        withAnimation {
            viewContext.delete(composition)
            
            do {
                try viewContext.save()
                print("✅ 体組成データを削除しました")
            } catch {
                print("❌ 削除エラー: \(error)")
            }
        }
    }
}
