//
//  WorkoutPhotoManager.swift
//  FitnessTracker
//  Models/Managers/WorkoutPhotoManager.swift
//
//  Created: 2025/11/03
//

import SwiftUI
import PhotosUI
import CoreData

// MARK: - 筋トレ写真マネージャー
class WorkoutPhotoManager: ObservableObject {
    @Published var todayPhotos: [WorkoutPhoto] = []
    
    // 写真を追加
    func addPhoto(imageData: Data, date: Date, context: NSManagedObjectContext) {
        let photo = WorkoutPhoto(context: context)
        photo.id = UUID()
        photo.imageData = imageData
        photo.date = date
        photo.createdAt = Date()
        
        do {
            try context.save()
            loadTodayPhotos(for: date, context: context)
            print("✅ 写真を保存しました")
        } catch {
            print("❌ 写真保存エラー: \(error)")
        }
    }
    
    // 写真を削除
    func deletePhoto(_ photo: WorkoutPhoto, context: NSManagedObjectContext) {
        // Optionalプロパティを安全に取得
        let calendar = Calendar.current
        let photoDate = photo.wrappedDate
        let startOfDay = calendar.startOfDay(for: photoDate)
        
        context.delete(photo)
        
        do {
            try context.save()
            loadTodayPhotos(for: startOfDay, context: context)
            print("✅ 写真を削除しました")
        } catch {
            print("❌ 写真削除エラー: \(error)")
            context.rollback()
        }
    }
    
    // 今日の写真を読み込み
    func loadTodayPhotos(for date: Date, context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<WorkoutPhoto> = WorkoutPhoto.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "date >= %@", startOfDay as NSDate),
            NSPredicate(format: "date < %@", endOfDay as NSDate)
        ])
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutPhoto.createdAt, ascending: true)]
        
        do {
            todayPhotos = try context.fetch(fetchRequest)
            print("✅ 写真を読み込み: \(todayPhotos.count)枚")
        } catch {
            print("❌ 写真読み込みエラー: \(error)")
            todayPhotos = []
        }
    }
}

// MARK: - 筋トレ写真セクション（コンパクト版）
struct WorkoutPhotoSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var photoManager = WorkoutPhotoManager()
    
    let selectedDate: Date
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingFullScreenPhoto: WorkoutPhoto?
    @State private var showingDeleteAlert = false
    @State private var photoToDelete: WorkoutPhoto?
    
    var body: some View {
        HStack(spacing: 12) {
            Text("今日の筋トレ写真")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            // 写真を横スクロールで表示
            if !photoManager.todayPhotos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(photoManager.todayPhotos) { photo in
                            if let imageData = photo.imageData,
                               let uiImage = UIImage(data: imageData) {
                                Button(action: {
                                    showingFullScreenPhoto = photo
                                }) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        
                        // 追加ボタン
                        addPhotoButton
                    }
                }
                .frame(height: 60)
            } else {
                // 写真がない場合は追加ボタンのみ
                addPhotoButton
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .onAppear {
            photoManager.loadTodayPhotos(for: selectedDate, context: viewContext)
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            photoManager.loadTodayPhotos(for: newValue, context: viewContext)
        }
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    photoManager.addPhoto(imageData: data, date: selectedDate, context: viewContext)
                }
                selectedPhoto = nil
            }
        }
        .fullScreenCover(item: $showingFullScreenPhoto) { photo in
            FullScreenPhotoView(
                photo: photo,
                onDelete: {
                    photoToDelete = photo
                    showingDeleteAlert = true
                },
                onDismiss: {
                    showingFullScreenPhoto = nil
                }
            )
        }
        .alert("写真を削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) {
                photoToDelete = nil
            }
            Button("削除", role: .destructive) {
                if let photo = photoToDelete {
                    photoManager.deletePhoto(photo, context: viewContext)
                }
                photoToDelete = nil
                showingFullScreenPhoto = nil
            }
        } message: {
            Text("この写真を削除しますか?")
        }
    }
    
    // MARK: - 追加ボタン
    private var addPhotoButton: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "camera.fill")
                        .foregroundColor(.blue)
                )
        }
    }
}

// MARK: - 全画面写真表示
struct FullScreenPhotoView: View {
    let photo: WorkoutPhoto
    let onDelete: () -> Void
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let imageData = photo.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                if scale < 1.0 {
                                    withAnimation {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                } else if scale > 5.0 {
                                    withAnimation {
                                        scale = 5.0
                                        lastScale = 5.0
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
            }
            
            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                    }
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                            .shadow(radius: 3)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}
