//
//  NutritionDisplayRow.swift
//  FitnessTracker
//

import SwiftUI

// MARK: - 栄養情報表示行
struct NutritionDisplayRow: View {
    let label: String
    let value: String
    let unit: String
    
    // Int用のイニシャライザ
    init(label: String, value: Int, unit: String) {
        self.label = label
        self.value = "\(value)"
        self.unit = unit
    }
    
    // String用のイニシャライザ
    init(label: String, value: String, unit: String) {
        self.label = label
        self.value = value
        self.unit = unit
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
}
