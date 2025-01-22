//
//  ParentAlbumDetailView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
import Combine
import WidgetKit

struct ParentAlbumDetailView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    @Environment(PhotoViewModel.self) var photoVM
    
    @State private var photo: Photo
    @State private var isShowingDeleteSheet: Bool = false
    @State private var isZooming: Bool = false
    
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
                    AsyncSquareImage(photo: photo)
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
                HStack(spacing: 30) {
                    IconBtn(Icon.loveReaction) {
                        // TODO: - 카운트 연결
                        HapticManager.instance.impact(style: .light)
                    }
                    .foregroundStyle(.pink)
                    
                    IconBtn(Icon.fireReaction) {
                        // TODO: - 카운트 연결
                        HapticManager.instance.impact(style: .light)
                    }
                    .foregroundStyle(.yellow)
                    
                    IconBtn(Icon.starReaction) {
                        // TODO: - 카운트 연결
                        HapticManager.instance.impact(style: .light)
                    }
                    .foregroundStyle(.teal)
                    
                    IconBtn(Icon.likeReaction) {
                        // TODO: - 카운트 연결
                        HapticManager.instance.impact(style: .light)
                    }
                    .foregroundStyle(.purple)
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
                    self.isShowingDeleteSheet = true
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
            VStack {
                Button("삭제하기", role: .destructive) {
                    Task.detached {
                        do {
                            // 1. 사진 삭제
                            try await photoVM.delete(photo)
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
        }
        .onDisappear {
            Task.detached(priority: .background) {
                // TODO: - 좋아요 개수 업데이트 로직 추가
            }
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
        ParentAlbumDetailView(photo: Photo.mock)
            .injectDIContainer()
            .preferredColorScheme(.dark)
    }
}
