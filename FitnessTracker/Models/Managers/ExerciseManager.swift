//
//  ExerciseManager.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/08/17.
//
import Foundation
import CoreData

class ExerciseManager: ObservableObject {
    
    // デフォルトの種目リスト
    static let defaultExercises: [String: [String]] = [
        "胸": ["ベンチプレス", "インクラインベンチプレス", "ダンベルフライ", "腕立て伏せ"],
        "背中": ["デッドリフト", "懸垂", "ラットプルダウン", "ベントオーバーロー"],
        "肩": ["ショルダープレス", "サイドレイズ", "リアレイズ", "アップライトロー"],
        "腕": ["バーベルカール", "トライセプスエクステンション", "ハンマーカール", "ディップス"],
        "脚": ["スクワット", "レッグプレス", "レッグカール", "カーフレイズ"],
        "腹筋": ["クランチ", "プランク", "レッグレイズ", "バイシクルクランチ"],
        "有酸素": ["ランニング", "サイクリング", "ウォーキング", "エリプティカル"]
    ]
    
    // 初期データをCore Dataに保存
    static func initializeDefaultExercises(context: NSManagedObjectContext) {
        // 既存データがあるかチェック
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCustom == false")
        
        do {
            let existingExercises = try context.fetch(fetchRequest)
            if !existingExercises.isEmpty {
                return // 既にデフォルトデータが存在する
            }
        } catch {
            print("デフォルト種目チェックエラー: \(error)")
        }
        
        // デフォルト種目を追加
        for (category, exercises) in defaultExercises {
            for exerciseName in exercises {
                let exercise = Exercise(context: context)
                exercise.name = exerciseName
                exercise.category = category
                exercise.isCustom = false
                exercise.createdAt = Date()
            }
        }
        
        do {
            try context.save()
            print("デフォルト種目を初期化しました")
        } catch {
            print("デフォルト種目保存エラー: \(error)")
        }
    }
    
    // カテゴリ別の種目を取得
    static func getExercises(for category: String, context: NSManagedObjectContext) -> [Exercise] {
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Exercise.isCustom, ascending: true), // デフォルト種目を先に表示
            NSSortDescriptor(keyPath: \Exercise.name, ascending: true)
        ]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("種目取得エラー: \(error)")
            return []
        }
    }
    
    // 新しい種目を追加
    static func addCustomExercise(name: String, category: String, context: NSManagedObjectContext) -> Bool {
        // 重複チェック
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name == %@", name),
            NSPredicate(format: "category == %@", category)
        ])
        
        do {
            let existingExercises = try context.fetch(fetchRequest)
            if !existingExercises.isEmpty {
                return false // 既に存在する
            }
        } catch {
            print("重複チェックエラー: \(error)")
            return false
        }
        
        // 新しい種目を追加
        let exercise = Exercise(context: context)
        exercise.name = name
        exercise.category = category
        exercise.isCustom = true
        exercise.createdAt = Date()
        
        do {
            try context.save()
            print("カスタム種目を追加しました: \(name)")
            return true
        } catch {
            print("カスタム種目保存エラー: \(error)")
            return false
        }
    }
    
    // カスタム種目を削除
    static func deleteCustomExercise(_ exercise: Exercise, context: NSManagedObjectContext) -> Bool {
        guard exercise.isCustom else {
            return false // デフォルト種目は削除できない
        }
        
        context.delete(exercise)
        
        do {
            try context.save()
            print("カスタム種目を削除しました: \(exercise.name)")
            return true
        } catch {
            print("カスタム種目削除エラー: \(error)")
            return false
        }
    }
}
