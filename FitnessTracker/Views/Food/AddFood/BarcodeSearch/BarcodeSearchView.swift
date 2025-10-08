//
//  BarcodeSearchView.swift
//  FitnessTracker
//  Views/Food/AddFood/BarcodeSearch/BarcodeSearchView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - バーコード検索画面
struct BarcodeSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let selectedDate: Date
    
    @State private var showingScanner = false
    @State private var showingProductDetail = false
    @State private var scannedBarcode = ""
    @State private var foundProduct: BarcodeProduct?
    @State private var isSearching = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingManualInput = false
    @State private var manualBarcode = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    
                    if !scannedBarcode.isEmpty {
                        scannedBarcodeView
                    }
                    
                    scanMethodButtons
                    
                    hintSection
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("バーコード検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView { barcode in
                    handleBarcodeScanned(barcode)
                }
            }
            .sheet(isPresented: $showingManualInput) {
                ManualBarcodeInputView(
                    barcode: $manualBarcode,
                    onSubmit: { barcode in
                        handleBarcodeScanned(barcode)
                    }
                )
            }
            .sheet(isPresented: $showingProductDetail) {
                if let product = foundProduct {
                    ProductDetailView(
                        product: product,
                        selectedDate: selectedDate
                    )
                    .environment(\.managedObjectContext, viewContext)
                }
            }
            .alert("結果", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("バーコードスキャン")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("商品のバーコードを読み取って\n栄養情報を自動取得します")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var scannedBarcodeView: some View {
        ScannedBarcodeView(
            barcode: scannedBarcode,
            isSearching: isSearching,
            foundProduct: foundProduct,
            onReset: resetScan,
            onProductTap: { showingProductDetail = true }
        )
    }
    
    private var scanMethodButtons: some View {
        VStack(spacing: 16) {
            ScanMethodButton(
                icon: "camera.viewfinder",
                title: "カメラでスキャン",
                subtitle: "バーコードをカメラで読み取り",
                color: .orange
            ) {
                showingScanner = true
            }
            
            ScanMethodButton(
                icon: "keyboard",
                title: "手動入力",
                subtitle: "バーコード番号を直接入力",
                color: .blue
            ) {
                showingManualInput = true
            }
        }
    }
    
    private var hintSection: some View {
        HintSectionView()
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // MARK: - Functions
    
    private func handleBarcodeScanned(_ barcode: String) {
        scannedBarcode = barcode
        searchProduct(barcode: barcode)
    }
    
    private func resetScan() {
        scannedBarcode = ""
        foundProduct = nil
        isSearching = false
    }
    
    private func searchProduct(barcode: String) {
        isSearching = true
        foundProduct = nil
        
        Task {
            do {
                let product = try await IntegratedSearchManager.shared.searchProductByBarcode(barcode)
                
                await MainActor.run {
                    isSearching = false
                    
                    if let product = product {
                        foundProduct = product
                        alertMessage = "商品が見つかりました"
                    } else {
                        alertMessage = "商品が見つかりませんでした\n手動で栄養情報を入力してください"
                    }
                    showingAlert = true
                }
                
            } catch {
                await MainActor.run {
                    isSearching = false
                    alertMessage = "検索中にエラーが発生しました: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

#Preview {
    BarcodeSearchView(selectedDate: Date())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
