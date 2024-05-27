//
//  ParentAlbumView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData

struct ParentAlbumView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(\.modelContext) var modelContext

    @Query(sort: \PhotoForSwiftData.uploadDate, order: .reverse) var photoForSwiftDatas: [PhotoForSwiftData]
    @Bindable var user: UserForSwiftData
    @State private var isLoading: Bool = false

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
                            }
                            
                            if let uiImage = UIImage(data: first.imgData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                                    .cornerRadius(10.0)
                                    .onTapGesture {
                                        navigationManager.push(to: .parentAlbumDetail(photo: first))
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
                                            navigationManager.push(to: .parentAlbumDetail(photo: photo))
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
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("앨범")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    Task {
                        isLoading = true
                        await syncPhotoData()
                        isLoading = false
                    }
                } label: {
                    Icon.refresh
                }
                .disabled(isLoading)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    navigationManager.push(to: .setting(role: .parent))
                } label: {
                    Icon.setting
                }
            }
        }
    }
}

extension ParentAlbumView {
    private func syncPhotoData() async {
        var updateCount = 0
        var addCount = 0
        var deleteCount = 0
        
        do {
            let photos = try await FirestoreService.shared.fetchPhotos(userName: user.name)
            var photoIds = Set<UUID>()
            
            for photo in photos {
                
                guard let photoIdString = photo.id,
                      let photoId = UUID(uuidString: photoIdString)
                else {
                    print("유효하지 않은 ID: \(String(describing: photo.id))")
                    continue
                }
                
                photoIds.insert(photoId)
                
                if let existingPhoto = photoForSwiftDatas.first(where: { $0.id == photoId }) {
                    if existingPhoto.likeCount != photo.likeCount {
                        updateCount += 1
                        existingPhoto.likeCount = photo.likeCount
                    }
                } else {
                    addCount += 1
                    let newPhotoForSwiftData = try await FirestoreService.shared.fetchPhotoForSwiftDataByPhoto(photo: photo)
                    modelContext.insert(newPhotoForSwiftData)
                }
            }
            
            for photoForSwiftData in photoForSwiftDatas {
                if !photoIds.contains(photoForSwiftData.id) {
                    deleteCount += 1
                    modelContext.delete(photoForSwiftData)
                }
            }
            
            try modelContext.save()
            
            print("총\(photos.count) 개의 이미지")
            print("\(updateCount + addCount + deleteCount) 개의 이미지 동기화함")
            print("\(updateCount) 개의 사진 업데이트됨")
            print("\(addCount) 개의 사진 추가됨")
            print("\(deleteCount) 개의 사진 삭제됨")
            
        } catch {
            print("사진 데이터 동기화 실패: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ParentAlbumView(user: UserForSwiftData(name: "", role: .child, email: ""))
            .environment(NavigationManager())
            .preferredColorScheme(.dark)
    }
}
