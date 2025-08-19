import SwiftUI

// MARK: - 設定画面（簡易版）
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("基本設定") {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("プロフィール設定")
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("通知設定")
                    }
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("データエクスポート")
                    }
                }
                
                Section("その他") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("ヘルプ")
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                        Text("アプリについて")
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}
