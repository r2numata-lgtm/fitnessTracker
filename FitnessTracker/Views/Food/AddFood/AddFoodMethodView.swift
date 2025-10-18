//
//  AddFoodMethodView.swift
//  FitnessTracker
//
//  食事記録方法選択画面（バーコード削除版）
//

import SwiftUI
import CoreData

// MARK: - 食事記録方法選択画面
struct AddFoodMethodView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let selectedDate: Date
    
    @State private var showingFoodSearch = false
    @State private var showingFoodHistory = false
    @State private var showingPhotoAnalysis = false
    @State private var showingComingSoonAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    // 記録方法選択カード
                    VStack(spacing: 16) {
                        // 1. 食材検索
                        methodCard(
                            icon: "magnifyingglass",
                            title: "食材を検索",
                            subtitle: "食材名で検索して栄養情報を記録",
                            color: .blue
                        ) {
                            showingFoodSearch = true
                        }
                        
                        // 2. 履歴から選択
                        methodCard(
                            icon: "clock.fill",
                            title: "履歴から選択",
                            subtitle: "過去に記録した食事から選択",
                            color: .green
                        ) {
                            showingFoodHistory = true
                        }
                        
                        // 3. AI解析（リリース後機能）
                        methodCard(
                            icon: "sparkles",
                            title: "AI解析",
                            subtitle: "写真から自動で栄養素を解析（近日公開）",
                            color: .purple,
                            isDisabled: true
                        ) {
                            showingComingSoonAlert = true
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("食事記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFoodSearch) {
                FoodSearchView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingFoodHistory) {
                FoodHistoryView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingPhotoAnalysis) {
                PhotoAnalysisView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .alert("近日公開", isPresented: $showingComingSoonAlert) {
                Button("OK") { }
            } message: {
                Text("AI解析機能は次回のアップデートでリリース予定です。\n楽しみにお待ちください！")
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("食事を記録")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("記録方法を選択してください")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    // カード生成用のヘルパー関数
    private func methodCard(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(isDisabled ? .gray : color)
                }
                
                // テキスト
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(isDisabled ? .gray : .primary)
                        
                        if isDisabled {
                            Text("SOON")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // 矢印
                Image(systemName: isDisabled ? "lock.fill" : "chevron.right")
                    .foregroundColor(isDisabled ? .gray : .secondary)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDisabled ? Color.gray.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Preview
struct AddFoodMethodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodMethodView(selectedDate: Date())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
