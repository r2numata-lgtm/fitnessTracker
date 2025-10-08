//
//  ReportFoodView.swift
//  FitnessTracker
//

import SwiftUI

struct ReportFoodView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let productId: String
    
    @State private var reportReason = ""
    @State private var selectedIssue: ReportIssue = .incorrectNutrition
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    enum ReportIssue: String, CaseIterable {
        case incorrectNutrition = "栄養情報が間違っている"
        case incorrectProduct = "食材情報が間違っている"
        case duplicate = "重複している"
        case other = "その他"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("報告理由") {
                    Picker("問題の種類", selection: $selectedIssue) {
                        ForEach(ReportIssue.allCases, id: \.self) { issue in
                            Text(issue.displayName).tag(issue)
                        }
                    }
                }
                
                Section("詳細（任意）") {
                    TextEditor(text: $reportReason)
                        .frame(height: 100)
                    
                    Text("具体的な問題点を記入してください")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Text("報告は匿名で送信され、データ品質の向上に役立てられます。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("間違いを報告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("送信") {
                        submitReport()
                    }
                }
            }
            .alert("結果", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("送信しました") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func submitReport() {
        Task {
            do {
                let note = "\(selectedIssue.displayName)\n\(reportReason)"
                try await SharedProductManager.shared.reportProduct(productId, note: note)
                
                await MainActor.run {
                    alertMessage = "報告を送信しました。\nご協力ありがとうございます。"
                    showingAlert = true
                }
            } catch SharedProductError.alreadyActioned {
                await MainActor.run {
                    alertMessage = "既にこの食材を報告済みです"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "報告の送信に失敗しました"
                    showingAlert = true
                }
            }
        }
    }
}
