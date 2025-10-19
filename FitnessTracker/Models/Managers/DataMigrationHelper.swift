//
//  DataMigrationHelper.swift
//  FitnessTracker
//  Models/Managers/DataMigrationHelper.swift
//
//  Created by FitnessTracker on 2025/10/19.
//

import Foundation
import CoreData

class DataMigrationHelper {
    
    // MARK: - 体組成データの日付を正規化
    /// 古い体組成データの日付を日付の開始時刻（0時0分0秒）に統一
    static func migrateBodyCompositionDates(context: NSManagedObjectContext) {
        let request: NSFetchRequest<BodyComposition> = BodyComposition.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: true)]
        
        do {
            let allCompositions = try context.fetch(request)
            print("📊 体組成データ総数: \(allCompositions.count)件")
            
            var migratedCount = 0
            var duplicates: [BodyComposition] = []
            
            let calendar = Calendar.current
            var dateMap: [Date: BodyComposition] = [:]
            
            for composition in allCompositions {
                let startOfDay = calendar.startOfDay(for: composition.date)
                
                // 日付が既に正規化されているかチェック
                if composition.date != startOfDay {
                    print("⚠️ 正規化が必要: \(composition.date) → \(startOfDay)")
                    
                    // 同じ日に既にデータがある場合は重複
                    if let existing = dateMap[startOfDay] {
                        print("🔄 重複データ発見: \(startOfDay) - 古い方を削除します")
                        
                        // 新しい方を残す（日時が後の方）
                        if composition.date > existing.date {
                            duplicates.append(existing)
                            dateMap[startOfDay] = composition
                            composition.date = startOfDay
                        } else {
                            duplicates.append(composition)
                        }
                    } else {
                        // 日付を正規化
                        composition.date = startOfDay
                        dateMap[startOfDay] = composition
                        migratedCount += 1
                    }
                } else {
                    dateMap[startOfDay] = composition
                }
            }
            
            // 重複データを削除
            for duplicate in duplicates {
                context.delete(duplicate)
                print("🗑️ 重複データを削除: \(duplicate.date)")
            }
            
            // 保存
            if context.hasChanges {
                try context.save()
                print("✅ マイグレーション完了:")
                print("   - 正規化: \(migratedCount)件")
                print("   - 削除: \(duplicates.count)件")
                print("   - 残存: \(dateMap.count)件")
            } else {
                print("✅ マイグレーション不要（データは既に正規化済み）")
            }
            
        } catch {
            print("❌ マイグレーションエラー: \(error)")
        }
    }
}
