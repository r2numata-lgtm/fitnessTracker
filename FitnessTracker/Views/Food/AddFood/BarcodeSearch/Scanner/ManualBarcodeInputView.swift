//
//  ManualBarcodeInputView.swift
//  FitnessTracker
//  Views/Food/AddFood/BarcodeSearch/Scanner/ManualBarcodeInputView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI

// MARK: - 手動バーコード入力View
struct ManualBarcodeInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var barcode: String
    let onSubmit: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                instructionText
                
                barcodeInput
                
                hintText
                
                Spacer()
            }
            .padding()
            .navigationTitle("手動入力")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
    }
    
    // MARK: - Subviews
    
    private var instructionText: some View {
        Text("バーコード番号を入力")
            .font(.title2)
            .fontWeight(.semibold)
    }
    
    private var barcodeInput: some View {
        TextField("例: 4901085141434", text: $barcode)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
    }
    
    private var hintText: some View {
        Text("通常13桁の数字です")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("検索") {
                onSubmit(barcode)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(barcode.isEmpty)
        }
    }
}

#Preview {
    ManualBarcodeInputView(
        barcode: .constant("4901085141434"),
        onSubmit: { barcode in
            print("検索: \(barcode)")
        }
    )
}
