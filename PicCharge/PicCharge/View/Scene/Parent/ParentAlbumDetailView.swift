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
    
    private let reactionPublisher = PassthroughSubject<Photo, Never>()
    
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
        let reactionDebounce = reactionPublisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        
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
        .overlay {
            if !isZooming {
                HStack(spacing: 30) {
                    ReactionButton(for: .love, color: .pink)
                    ReactionButton(for: .fire, color: .yellow)
                    ReactionButton(for: .star, color: .teal)
                    ReactionButton(for: .like, color: .purple)
                }
                .padding(.top, 450)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
            Button("삭제하기", role: .destructive) { Task.detached { await deletePhoto() } }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: photoVM.photos) { oldValue, newValue in
            // 현재 보고 있는 photo 업데이트
            guard let index = oldValue.firstIndex(of: photo),
                  0..<newValue.count ~= index
            else { return }
            
            self.photo = newValue[index]
        }
        .onReceive(reactionDebounce) { photo in
            Task.detached { await photoVM.updatePhotoReaction(photo) }
        }
    }
    
    private func deletePhoto() async {
        do {
            // 1. 사진 삭제
            try await photoVM.delete(photo)
            // 2. 위젯 리로드
            WidgetCenter.shared.reloadAllTimelines()
            // 3. 남은 Photo 없다면 이전 화면으로
            await MainActor.run {
                if photoVM.photos.isEmpty { navigationManager.pop() }
            }
            
        } catch {
            // 4. 에러 처리
            GlobalAlert.shared.show(message: error.localizedDescription)
        }
    }
    
    @ViewBuilder
    private func ReactionButton(for reaction: Reaction.Kind, color: Color) -> some View {
        
        IconBtn(reaction.icon) {
            photo.reaction.increment(for: reaction)
            reactionPublisher.send(photo)
            HapticManager.instance.impact(style: .light)
        }
        .foregroundStyle(color)
    }
}

#Preview {
    NavigationStack {
        ParentAlbumDetailView(photo: .withDataMock1)
            .injectPreviewDIContainer(
                user: .parentMock,
                photos: [.withDataMock1, .withDataMock2, .withDataMock3],
                response: .success
            )
            .preferredColorScheme(.dark)
    }
}
