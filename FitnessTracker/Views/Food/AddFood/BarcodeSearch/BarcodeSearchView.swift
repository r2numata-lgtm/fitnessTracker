//
//  BarcodeSearchView.swift
//  FitnessTracker
//  Views/Food/AddFood/BarcodeSearch/BarcodeSearchView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData
import AVFoundation

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
                    // ヘッダー
                    VStack(spacing: 12) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text("バーコードスキャン")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("商品のバーコードを読み取って\n栄養情報を自動取得します")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    // スキャン結果表示
                    if !scannedBarcode.isEmpty {
                        scannedBarcodeView
                    }
                    
                    // スキャン方法選択
                    scanMethodButtons
                    
                    // 使い方のヒント
                    hintSection
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("バーコード検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView { barcode in
                    scannedBarcode = barcode
                    searchProduct(barcode: barcode)
                }
            }
            .sheet(isPresented: $showingManualInput) {
                ManualBarcodeInputView(
                    barcode: $manualBarcode,
                    onSubmit: { barcode in
                        scannedBarcode = barcode
                        searchProduct(barcode: barcode)
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
    
    private var scannedBarcodeView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("スキャン結果")
                        .font(.headline)
                    
                    Text(scannedBarcode)
                        .font(.monospaced(.body)())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("リセット") {
                    resetScan()
                }
                .foregroundColor(.blue)
            }
            
            if isSearching {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("商品情報を検索中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else if let product = foundProduct {
                ProductSummaryCard(product: product) {
                    showingProductDetail = true
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var scanMethodButtons: some View {
        VStack(spacing: 16) {
            // カメラでスキャン
            ScanMethodButton(
                icon: "camera.viewfinder",
                title: "カメラでスキャン",
                subtitle: "バーコードをカメラで読み取り",
                color: .orange
            ) {
                showingScanner = true
            }
            
            // 手動入力
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
        VStack(alignment: .leading, spacing: 12) {
            Text("スキャンのコツ")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HintRow(icon: "lightbulb.fill", text: "明るい場所でスキャンする")
                HintRow(icon: "camera.viewfinder", text: "バーコード全体がフレーム内に入るように")
                HintRow(icon: "hand.raised.fill", text: "手ブレしないよう安定させる")
                HintRow(icon: "magnifyingglass", text: "商品パッケージのバーコードを探す")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Functions
    
    private func resetScan() {
        scannedBarcode = ""
        foundProduct = nil
        isSearching = false
    }
    
    private func searchProduct(barcode: String) {
        isSearching = true
        
        // TODO: 実際の商品データベースAPI呼び出し
        // 現在は仮のデータを使用
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let mockProduct = getMockProduct(for: barcode) {
                foundProduct = mockProduct
                alertMessage = "商品が見つかりました"
            } else {
                alertMessage = "商品が見つかりませんでした\n手動で栄養情報を入力してください"
            }
            isSearching = false
            showingAlert = true
        }
    }
    
    private func getMockProduct(for barcode: String) -> BarcodeProduct? {
        // 仮のデータベース
        let mockProducts = [
            "4901085141434": BarcodeProduct(
                barcode: "4901085141434",
                name: "おにぎり 鮭",
                brand: "セブンイレブン",
                nutrition: NutritionInfo(
                    calories: 180,
                    protein: 4.2,
                    fat: 1.8,
                    carbohydrates: 35.1,
                    sugar: 34.8,
                    servingSize: 110
                ),
                category: "おにぎり・弁当",
                packageSize: "110g"
            ),
            "4902102072448": BarcodeProduct(
                barcode: "4902102072448",
                name: "カップヌードル",
                brand: "日清",
                nutrition: NutritionInfo(
                    calories: 351,
                    protein: 10.5,
                    fat: 14.6,
                    carbohydrates: 44.9,
                    sugar: 42.8,
                    servingSize: 77
                ),
                category: "インスタント食品",
                packageSize: "77g"
            )
        ]
        
        return mockProducts[barcode]
    }
}

// MARK: - Helper Views

struct ScanMethodButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProductSummaryCard: View {
    let product: BarcodeProduct
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let brand = product.brand {
                            Text(brand)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(product.nutrition.calories))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("タップして詳細を確認")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if let packageSize = product.packageSize {
                        Text(packageSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Scanner View

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onBarcodeDetected: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BarcodeScannerDelegate {
        let parent: BarcodeScannerView
        
        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func barcodeDetected(_ barcode: String) {
            parent.onBarcodeDetected(barcode)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func scanningFailed() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Barcode Scanner Controller

protocol BarcodeScannerDelegate: AnyObject {
    func barcodeDetected(_ barcode: String)
    func scanningFailed()
}

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: BarcodeScannerDelegate?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.scanningFailed()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.scanningFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
        } else {
            delegate?.scanningFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            captureSession.stopRunning()
            delegate?.barcodeDetected(stringValue)
        }
    }
}

// MARK: - Manual Input View

struct ManualBarcodeInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var barcode: String
    let onSubmit: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("バーコード番号を入力")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextField("例: 4901085141434", text: $barcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Text("通常13桁の数字です")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("手動入力")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
    }
}

// MARK: - Product Detail View (仮実装)

struct ProductDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let product: BarcodeProduct
    let selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("商品詳細")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("詳細実装はSTEP5-Bで予定")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading) {
                    Text(product.fullDisplayName)
                        .font(.headline)
                    Text("\(Int(product.nutrition.calories))kcal")
                        .foregroundColor(.orange)
                }
            }
            .navigationTitle("商品詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // TODO: Core Dataに保存
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct BarcodeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeSearchView(selectedDate: Date())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
