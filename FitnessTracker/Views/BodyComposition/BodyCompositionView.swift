//
//  BodyCompositionView.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI
import CoreData

struct BodyCompositionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddEntry = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)],
        animation: .default)
    private var bodyCompositions: FetchedResults<BodyComposition>
    
    var latestEntry: BodyComposition? {
        bodyCompositions.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 現在の体組成表示
                    CurrentStatsCard(bodyComposition: latestEntry)
                    
                    // 基礎代謝計算結果
                    BMRCard(bodyComposition: latestEntry)
                    
                    // 履歴グラフ（簡易版）
                    if !bodyCompositions.isEmpty {
                        HistoryChartCard(bodyCompositions: Array(bodyCompositions.prefix(30)))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("体組成管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEntry = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddBodyCompositionView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

// MARK: - 現在の体組成カード
struct CurrentStatsCard: View {
    let bodyComposition: BodyComposition?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("現在の体組成")
                .font(.headline)
            
            if let composition = bodyComposition {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    StatItem(title: "身長", value: "\(Int(composition.height))cm", color: .blue)
                    StatItem(title: "体重", value: String(format: "%.1fkg", composition.weight), color: .green)
                    
                    if composition.bodyFatPercentage > 0 {
                        StatItem(title: "体脂肪率", value: String(format: "%.1f%%", composition.bodyFatPercentage), color: .orange)
                    }
                    
                    StatItem(title: "BMI", value: String(format: "%.1f", calculateBMI(composition)), color: .purple)
                }
                
                Text("最終更新: \(composition.date, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
            } else {
                Text("データがありません")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    private func calculateBMI(_ composition: BodyComposition) -> Double {
        let heightInMeters = composition.height / 100
        return composition.weight / (heightInMeters * heightInMeters)
    }
}

// MARK: - 統計アイテム
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

// MARK: - 基礎代謝カード
struct BMRCard: View {
    let bodyComposition: BodyComposition?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("基礎代謝")
                .font(.headline)
            
            if let composition = bodyComposition {
                HStack {
                    VStack(alignment: .leading) {
                        Text("基礎代謝量 (BMR)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(composition.basalMetabolicRate))kcal/日")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("活動代謝量 (TDEE)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(composition.basalMetabolicRate * 1.6))kcal/日")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
                
                Text("※ 活動代謝量は軽度の活動を想定した推定値です")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("体組成データを入力してください")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 履歴グラフカード
struct HistoryChartCard: View {
    let bodyCompositions: [BodyComposition]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("体重の推移")
                .font(.headline)
            
            // 簡易グラフ表示
            WeightChart(data: bodyCompositions)
                .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 体重グラフ
struct WeightChart: View {
    let data: [BodyComposition]
    
    var body: some View {
        GeometryReader { geometry in
            let maxWeight = data.map { $0.weight }.max() ?? 100
            let minWeight = data.map { $0.weight }.min() ?? 50
            let weightRange = maxWeight - minWeight
            
            Path { path in
                let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                
                for (index, composition) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedWeight = (composition.weight - minWeight) / max(weightRange, 1)
                    let y = geometry.size.height - (normalizedWeight * geometry.size.height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.green, lineWidth: 2)
            
            // データポイント
            ForEach(Array(data.enumerated()), id: \.offset) { index, composition in
                let x = CGFloat(index) * (geometry.size.width / CGFloat(max(data.count - 1, 1)))
                let normalizedWeight = (composition.weight - minWeight) / max(weightRange, 1)
                let y = geometry.size.height - (normalizedWeight * geometry.size.height)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                    .position(x: x, y: y)
            }
        }
    }
}

// MARK: - 体組成追加画面
struct AddBodyCompositionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var height: Double = 170
    @State private var weight: Double = 70
    @State private var bodyFatPercentage: Double = 0
    @State private var age: Int = 30
    @State private var gender: Gender = .male
    @State private var activityLevel: ActivityLevel = .moderate
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    HStack {
                        Text("身長(cm)")
                        Spacer()
                        TextField("170", value: $height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("体重(kg)")
                        Spacer()
                        TextField("70", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("年齢")
                        Spacer()
                        TextField("30", value: $age, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("性別", selection: $gender) {
                        Text("男性").tag(Gender.male)
                        Text("女性").tag(Gender.female)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("詳細情報") {
                    HStack {
                        Text("体脂肪率(%)")
                        Spacer()
                        TextField("0", value: $bodyFatPercentage, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("活動レベル", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                }
                
                Section("計算結果") {
                    HStack {
                        Text("BMI")
                        Spacer()
                        Text(String(format: "%.1f", calculateBMI()))
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("基礎代謝量")
                        Spacer()
                        Text("\(Int(calculateBMR()))kcal/日")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("推定消費カロリー")
                        Spacer()
                        Text("\(Int(calculateTDEE()))kcal/日")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("体組成記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveBodyComposition()
                    }
                }
            }
        }
    }
    
    private func calculateBMI() -> Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    private func calculateBMR() -> Double {
        // Harris-Benedict式
        switch gender {
        case .male:
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case .female:
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    private func calculateTDEE() -> Double {
        return calculateBMR() * activityLevel.multiplier
    }
    
    private func saveBodyComposition() {
        let newComposition = BodyComposition(context: viewContext)
        newComposition.date = Date()
        newComposition.height = height
        newComposition.weight = weight
        newComposition.bodyFatPercentage = bodyFatPercentage
        newComposition.basalMetabolicRate = calculateBMR()
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("保存エラー: \(error)")
        }
    }
}



// MARK: - 日付フォーマッター
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()

struct BodyCompositionView_Previews: PreviewProvider {
    static var previews: some View {
        BodyCompositionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
