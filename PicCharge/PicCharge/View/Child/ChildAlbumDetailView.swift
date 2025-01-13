//
//  ChildAlbumDetailView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ChildAlbumDetailView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(PhotoViewModel.self) var photoVM

    @State private var photo: Photo
    @State private var isShowingDeleteSheet: Bool = false
    @State private var isZooming: Bool = false
    
    var loveCount: Int { 12 }
    var fireCount: Int { 34 }
    var starCount: Int { 56 }
    var likeCount: Int { 78 }
    
    private var photoForShare: PhotoShareDTO {
        return PhotoShareDTO(
            imgData: photo.imgData ?? Data(),
            uploadDate: photo.uploadDate
        )
    }
    
    init(photo: Photo) {
        self.photo = photo
    }
    
    var body: some View {
        TabView(selection: $photo) {
            ForEach(photoVM.photos) { photo in
                VStack {
                    SquareImage(data: photo.imgData)
                        .zoomable(isZooming: $isZooming)
                        .padding(.top, 72)
                    
                    Spacer()
                }
                .tag(photo)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay {
            if !isZooming {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Icon.loveReaction.font(.system(size: 36))
                        Text("\(loveCount)")
                    }
                    .foregroundStyle(.pink)
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Icon.fireReaction.font(.system(size: 36))
                        Text("\(fireCount)")
                    }
                    .foregroundStyle(.yellow)
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Icon.starReaction.font(.system(size: 36))
                        Text("\(starCount)")
                    }
                    .foregroundStyle(.teal)
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Icon.likeReaction.font(.system(size: 36))
                        Text("\(likeCount)")
                    }
                    .foregroundStyle(.purple)
                    
                    Spacer()
                }
                .padding(.top, 450)
            }
        }
        .navigationTitle(photo.uploadDate.toKR())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isZooming ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            Menu {
                ShareLink(item: photoForShare,
                          preview: SharePreview(photoForShare.caption,
                                                image: photoForShare.image)
                ) {
                    Icon.share
                    Text("공유하기")
                }
                
                Button(role: .destructive) {
                    isShowingDeleteSheet = true
                } label: {
                    Icon.trash
                    Text("삭제하기")
                }
            } label: {
                Icon.menu
            }
        }
        .confirmationDialog(
            "사진을 삭제하시겠습니까? \n 삭제하면 되돌릴 수 없고, 저희가 슬퍼요.",
            isPresented: $isShowingDeleteSheet,
            titleVisibility: .visible
        ) {
            Button("삭제하기", role: .destructive) {
                Task.detached {
                    do {
                        // 1. 사진 삭제
                        try await photoVM.deletePhoto(photo)
                        // 2. 위젯 리로드
                        WidgetCenter.shared.reloadAllTimelines()
                        // 3. 남은 Photo 없다면 이전 화면으로
                        await MainActor.run {
                            if photoVM.photos.isEmpty {
                                navigationManager.pop()
                            }
                        }
                    } catch {
                        // 4. 에러 처리
                        await GlobalAlert.shared.show(message: error.localizedDescription)
                    }
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: photoVM.photos) { oldValue, newValue in
            // 현재 보고 있는 photo 업데이트
            guard let index = oldValue.firstIndex(of: photo),
                  0..<newValue.count ~= index
            else { return }

            self.photo = newValue[index]
        }
    }
}

#Preview {
    NavigationStack {
        ChildAlbumDetailView(photo: Photo.mocks.first!)
            .injectDIContainer()
            .preferredColorScheme(.dark)
    }
}
