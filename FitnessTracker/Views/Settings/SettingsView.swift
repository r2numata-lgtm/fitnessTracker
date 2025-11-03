//
//  SettingsView.swift
//  FitnessTracker
//

import SwiftUI

// MARK: - 設定画面
struct SettingsView: View {
    @AppStorage("userActivityLevel") private var activityLevelString: String = ActivityLevel.light.rawValue
    
    private var selectedActivityLevel: ActivityLevel {
        get {
            ActivityLevel(rawValue: activityLevelString) ?? .light
        }
        set {
            activityLevelString = newValue.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: ActivityLevelSettingView(selectedLevel: selectedActivityLevel)) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("活動レベル")
                                    .font(.body)
                                Text(selectedActivityLevel.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                } header: {
                    Text("カロリー計算")
                } footer: {
                    Text("Apple Watchや歩数データがない場合に、活動レベルから活動代謝を推定します")
                }
                
                Section("基本設定") {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                        Text("プロフィール設定")
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        Text("通知設定")
                    }
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.purple)
                        Text("データエクスポート")
                    }
                }
                
                Section("その他") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                        Text("ヘルプ")
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        Text("アプリについて")
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

// MARK: - 活動レベル設定画面
struct ActivityLevelSettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("userActivityLevel") private var activityLevelString: String = ActivityLevel.light.rawValue
    
    let selectedLevel: ActivityLevel
    @State private var tempSelectedLevel: ActivityLevel
    
    init(selectedLevel: ActivityLevel) {
        self.selectedLevel = selectedLevel
        self._tempSelectedLevel = State(initialValue: selectedLevel)
    }
    
    var body: some View {
        List {
            Section {
                ForEach(ActivityLevel.allCases) { level in
                    Button(action: {
                        tempSelectedLevel = level
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(level.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("係数: ×\(String(format: "%.2f", level.multiplier))")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
                            
                            Spacer()
                            
                            if tempSelectedLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } header: {
                Text("普段の活動量を選択")
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("選択した活動レベルに基づいて活動代謝が計算されます")
                    
                    Divider()
                    
                    Text("優先順位:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("1.")
                            Image(systemName: "applewatch")
                            Text("Apple Watch データ")
                        }
                        .font(.caption2)
                        
                        HStack(spacing: 6) {
                            Text("2.")
                            Image(systemName: "location.fill")
                            Text("移動距離データ")
                        }
                        .font(.caption2)
                        
                        HStack(spacing: 6) {
                            Text("3.")
                            Image(systemName: "figure.walk")
                            Text("歩数データ")
                        }
                        .font(.caption2)
                        
                        HStack(spacing: 6) {
                            Text("4.")
                            Image(systemName: "person.fill")
                            Text("活動レベル係数（このページ）")
                        }
                        .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("活動レベル設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    activityLevelString = tempSelectedLevel.rawValue
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    SettingsView()
}
