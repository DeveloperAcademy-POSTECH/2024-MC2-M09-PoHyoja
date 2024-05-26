//
//  ChildAlbumView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData

struct ChildAlbumView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \PhotoForSwiftData.uploadDate, order: .reverse) var photoForSwiftDatas: [PhotoForSwiftData]
    @Query var userForSwiftDatas: [UserForSwiftData]
    @State private var hasLoadedData = false

    //geometryReader로 3등분
    let columnLayout = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        Group {
            if let first = photoForSwiftDatas.first {
                ScrollView {
                    Divider()
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("최근 업로드 사진")
                                    .font(.headline)
                                    .foregroundStyle(.txtVibrantSecondary)
                                Spacer()
                                Button(action: {
                                    Task {
                                        await syncPhotoData()
                                    }
                                }){
                                    Image(systemName: "arrow.clockwise")
                                }
                            }
                            
                            if let uiImage = UIImage(data: first.imgData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                                    .cornerRadius(10.0)
                                    .onTapGesture {
                                        navigationManager.push(to: .childAlbumDetail(photo: first))
                                    }
                            }
                            
                            Text(first.uploadDate.toKR())
                                .font(.subheadline)
                            
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            Text("충전 기록")
                                .font(.headline)
                                .foregroundStyle(.txtVibrantSecondary)
                        }
                        .padding(.horizontal, 16)
                        
                        LazyVGrid(columns: columnLayout, spacing: 3) {
                            ForEach(photoForSwiftDatas.dropFirst()) { photo in
                                if let uiImage = UIImage(data: photo.imgData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                        .onTapGesture {
                                            navigationManager.push(to: .childAlbumDetail(photo: photo))
                                        }
                                }
                            }
                        }
                    }
                    
                }
            } else {
                Text("아직 업로드된 사진이 없어요.")
            }
        }
        .onAppear {
            Task {
                if !hasLoadedData {
                    await syncPhotoData()
                    hasLoadedData = true
                }
            }
        }
    }
}

extension ChildAlbumView {
    private func syncPhotoData() async {
        var updateCount = 0
        var addCount = 0
        var deleteCount = 0
        guard let swiftDataUser = userForSwiftDatas.first else {
            print("로컬에 유저 데이터 없음")
            return
        }
        
        do {
            let photos = try await FirestoreService.shared.fetchPhotos(userName: swiftDataUser.name)
            var photoIds = Set<UUID>()
            for photo in photos {
                guard let photoIdString = photo.id, let photoId = UUID(uuidString: photoIdString) else {
                    print("유효하지 않은 ID: \(String(describing: photo.id))")
                    continue
                }
                photoIds.insert(photoId)
                // photoForSwiftDatas에서 같은 id를 가진 객체를 찾음
                if let existingPhoto = fetchExistingPhoto(with: photoId) {
                    print("2.1 photo id:\(existingPhoto.id)")
                    updateExistingPhotosLikeCount(existingPhoto, with: photo)
                    updateCount += 1
                } else {
                    addCount += 1
                    let newPhotoForSwiftData = try await FirestoreService.shared.fetchPhotoForSwiftDataByPhoto(photo: photo)
                    modelContext.insert(newPhotoForSwiftData)
                }
            }
            for photoForSwiftData in photoForSwiftDatas {
                if !photoIds.contains(photoForSwiftData.id) {
                    modelContext.delete(photoForSwiftData)
                    deleteCount += 1
                }
            }
            
            try modelContext.save()
            print("\(photos.count) 개의 이미지 동기화함")
            print("\(updateCount) 개의 사진 업데이트됨")
            print("\(addCount) 개의 사진 추가됨")
            print("\(deleteCount) 개의 사진 삭제됨")
        } catch {
            print("사진 데이터 동기화 실패: \(error)")
        }
    }
    
    private func fetchExistingPhoto(with id: UUID) -> PhotoForSwiftData? {
        return photoForSwiftDatas.first(where: { $0.id == id })
    }
    
    private func updateExistingPhotosLikeCount(_ existingPhoto: PhotoForSwiftData, with newPhoto: Photo) {
        existingPhoto.likeCount = newPhoto.likeCount
    }
}

#Preview {
    NavigationStack {
        ChildAlbumView()
            .environment(NavigationManager())
            .preferredColorScheme(.dark)
            .navigationTitle("앨범")
    }
}
