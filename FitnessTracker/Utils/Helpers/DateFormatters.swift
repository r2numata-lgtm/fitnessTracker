//
//  DateFormatters.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/19.
//

import Foundation

// MARK: - 日付フォーマッター集
struct DateFormatters {
    
    /// 標準的な日付表示用 (2025年8月19日)
    static let standard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    /// 日付と時刻表示用 (2025年8月19日 9:24)
    static let dateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    /// 月表示用 (2025年8月)
    static let month: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    /// 日付のみ表示用 (19)
    static let dayOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    /// 時刻のみ表示用 (9:24)
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
}
