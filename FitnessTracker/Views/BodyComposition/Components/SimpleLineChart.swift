//
//  SimpleLineChart.swift
//  FitnessTracker
//  Views/BodyComposition/Components/SimpleLineChart.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import SwiftUI

struct SimpleLineChart: View {
    let data: [BodyComposition]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let sortedData = data.sorted { $0.date < $1.date }
            let weights = sortedData.map { $0.weight }
            
            guard !weights.isEmpty else {
                return AnyView(
                    Text("データがありません")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
            }
            
            let maxWeight = weights.max() ?? 100
            let minWeight = weights.min() ?? 50
            let range = maxWeight - minWeight
            let adjustedRange = range > 0 ? range : 10
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            return AnyView(
                ZStack(alignment: .bottomLeading) {
                    // 背景グリッド
                    gridLines(height: height)
                    
                    // 折れ線グラフ
                    Path { path in
                        for (index, weight) in weights.enumerated() {
                            let x = width * CGFloat(index) / CGFloat(max(weights.count - 1, 1))
                            let normalizedValue = (weight - minWeight) / adjustedRange
                            let y = height - (height * normalizedValue)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    
                    // データポイント
                    ForEach(Array(weights.enumerated()), id: \.offset) { index, weight in
                        let x = width * CGFloat(index) / CGFloat(max(weights.count - 1, 1))
                        let normalizedValue = (weight - minWeight) / adjustedRange
                        let y = height - (height * normalizedValue)
                        
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                    
                    // Y軸ラベル
                    VStack {
                        Text(String(format: "%.1fkg", maxWeight))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(String(format: "%.1fkg", minWeight))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                    .offset(x: -40)
                }
            )
        }
    }
    
    private func gridLines(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<5) { _ in
                Divider()
                    .background(Color.gray.opacity(0.2))
                Spacer()
            }
            Divider()
                .background(Color.gray.opacity(0.2))
        }
        .frame(height: height)
    }
}

// MARK: - 体重推移グラフカード
struct WeightChartCard: View {
    let bodyCompositions: [BodyComposition]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("体重の推移")
                    .font(.headline)
                
                Spacer()
                
                if bodyCompositions.count > 1 {
                    Text("過去\(min(bodyCompositions.count, 30))件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if bodyCompositions.count < 2 {
                Text("2件以上のデータが必要です")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            } else {
                SimpleLineChart(
                    data: Array(bodyCompositions.prefix(30)),
                    color: .green
                )
                .frame(height: 200)
                .padding(.leading, 40)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}
