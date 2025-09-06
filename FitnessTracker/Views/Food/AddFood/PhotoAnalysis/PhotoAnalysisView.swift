//
//  PhotoAnalysisView.swift
//  FitnessTracker
//  Views/Food/AddFood/PhotoAnalysis/PhotoAnalysisView.swift
//
//  Created by 沼田蓮二朗 on 2025/09/06.
//

import SwiftUI
import CoreData

// MARK: - 写真解析画面
struct PhotoAnalysisView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let selectedDate: Date
    
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var analysisResult: PhotoAnalysisResult?
    @State private var showingResult = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // ヘッダー
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("写真から記録")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("料理の写真を撮影または選択して\nAIで栄養素を自動算出します")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    // 選択された画像表示
                    if let image = selectedImage {
                        selectedImageView(image)
                    } else {
                        photoSelectionButtons
                    }
                    
                    // 使い方のヒント
                    if selectedImage == nil {
                        hintSection
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("写真解析")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                if selectedImage != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("リセット") {
                            resetSelection()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView { image in
                    selectedImage = image
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView { image in
                    selectedImage = image
                }
            }
            .sheet(isPresented: $showingResult) {
                if let result = analysisResult {
                    PhotoResultView(
                        result: result,
                        selectedDate: selectedDate,
                        originalImage: selectedImage
                    )
                    .environment(\.managedObjectContext, viewContext)
                }
            }
            .alert("エラー", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func selectedImageView(_ image: UIImage) -> some View {
        VStack(spacing: 20) {
            // 画像表示
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // 解析状態
            if isAnalyzing {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("AI解析中...")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("料理を認識しています")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                // 解析開始ボタン
                Button(action: analyzePhoto) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("AI解析を開始")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isAnalyzing)
            }
        }
    }
    
    private var photoSelectionButtons: some View {
        VStack(spacing: 16) {
            // カメラで撮影
            PhotoSelectionButton(
                icon: "camera.fill",
                title: "カメラで撮影",
                subtitle: "新しく料理を撮影する",
                color: .blue
            ) {
                showingCamera = true
            }
            
            // ギャラリーから選択
            PhotoSelectionButton(
                icon: "photo.fill",
                title: "ギャラリーから選択",
                subtitle: "保存済みの写真を選択する",
                color: .green
            ) {
                showingImagePicker = true
            }
        }
    }
    
    private var hintSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("より正確な解析のために")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HintRow(icon: "lightbulb.fill", text: "明るい場所で撮影する")
                HintRow(icon: "viewfinder", text: "料理全体が写るように撮る")
                HintRow(icon: "hand.raised.fill", text: "真上から撮影すると認識精度が向上")
                HintRow(icon: "exclamationmark.triangle.fill", text: "複数の料理がある場合は個別に撮影")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Functions
    
    private func resetSelection() {
        selectedImage = nil
        analysisResult = nil
        isAnalyzing = false
    }
    
    private func analyzePhoto() {
        guard let image = selectedImage else { return }
        
        isAnalyzing = true
        
        // TODO: 実際のAI解析APIを呼び出し
        // 現在は仮のデータを使用
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let mockResult = createMockAnalysisResult()
            analysisResult = mockResult
            isAnalyzing = false
            showingResult = true
        }
    }
    
    private func createMockAnalysisResult() -> PhotoAnalysisResult {
        let detectedFoods = [
            DetectedFood(
                name: "白米",
                estimatedWeight: 150,
                nutrition: NutritionInfo(
                    calories: 252,
                    protein: 3.5,
                    fat: 0.3,
                    carbohydrates: 55.7,
                    sugar: 55.7,
                    servingSize: 150
                ),
                confidence: 0.89,
                boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.3, height: 0.25),
                category: "穀物"
            ),
            DetectedFood(
                name: "鶏の唐揚げ",
                estimatedWeight: 100,
                nutrition: NutritionInfo(
                    calories: 290,
                    protein: 16.0,
                    fat: 18.0,
                    carbohydrates: 10.0,
                    sugar: 8.0,
                    servingSize: 100
                ),
                confidence: 0.76,
                boundingBox: CGRect(x: 0.5, y: 0.2, width: 0.25, height: 0.3),
                category: "揚げ物"
            )
        ]
        
        return PhotoAnalysisResult(
            detectedFoods: detectedFoods,
            overallConfidence: 0.82,
            processingTime: 2.1,
            imageSize: CGSize(width: 1024, height: 768)
        )
    }
}

// MARK: - Helper Views

struct PhotoSelectionButton: View {
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

struct HintRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Camera and Image Picker

struct CameraView: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - 写真解析結果画面（仮実装）
struct PhotoResultView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let result: PhotoAnalysisResult
    let selectedDate: Date
    let originalImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("解析結果")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("詳細実装はSTEP4-C-3で予定")
                    .foregroundColor(.secondary)
                
                Text("検出された食材: \(result.detectedFoods.count)種類")
                    .font(.subheadline)
                
                ForEach(result.detectedFoods.prefix(3), id: \.id) { food in
                    VStack(alignment: .leading) {
                        Text(food.name)
                            .font(.headline)
                        Text("\(Int(food.nutrition.calories))kcal")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("解析結果")
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

struct PhotoAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoAnalysisView(selectedDate: Date())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
