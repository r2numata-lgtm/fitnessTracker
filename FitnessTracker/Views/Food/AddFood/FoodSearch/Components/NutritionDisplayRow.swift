//
//  NutritionDisplayRow.swift
//  FitnessTracker
//  Views/Food/AddFood/FoodSearch/Components/NutritionDisplayRow.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - 栄養情報表示行
struct NutritionDisplayRow: View {
    let label: String
    let value: Int
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)")
                .fontWeight(.semibold)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    List {
        NutritionDisplayRow(label: "カロリー", value: 356, unit: "kcal")
        NutritionDisplayRow(label: "たんぱく質", value: 23, unit: "g")
    }
}
