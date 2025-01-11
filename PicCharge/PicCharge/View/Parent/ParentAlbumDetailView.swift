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
    @State private var isLiked: Bool = false
    @State private var cancellable: AnyCancellable?
    @State private var likeAnimationIDs: [UUID] = []
    
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
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack {
                TabView(selection: $photo) {
                    ForEach(photoVM.photos) { photo in
                        SquareImage(data: photo.imgData)
                            .zoomable(isZooming: $isZooming)
                            .tag(photo)
                            .padding(.bottom, 166)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            
            ForEach(likeAnimationIDs, id: \.self) { id in
                LottieView(jsonName: "LikeAnimation", loopMode: .playOnce)
                    .transition(.opacity)
                    .opacity(0.5)
                    .frame(width: 160, height: 240)
                    .offset(y: 188) // iPhone 13 Pro Max, iPhone 15 Pro: 150
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            likeAnimationIDs.removeAll { $0 == id }
                        }
                    }
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Spacer()
                    
                    Button {
                        photo.likeCount += 1
                        likeAnimationIDs.append(UUID())
                        self.resetTimer()
                        HapticManager.instance.impact(style: .light)
                    } label: {
                        Icon.heart
                            .font(.system(size: 50))
                            .foregroundColor(.grpRed)
                    }
                    
                    Text(" ")
                        .font(.body)
                        .fontWeight(.bold)
                }
            }
            .opacity(isZooming ? 0 : 1)
            .padding(.bottom, 80)
        }
        .navigationTitle(photo.uploadDate.toKR())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isZooming ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            Menu {
                ShareLink(
                    item: photoForShare,
                    preview: SharePreview(photoForShare.caption, image: photoForShare.image)
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
        }
        .onDisappear {
            guard let cancellable else { return }
            
            cancellable.cancel()
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
    
    private func resetTimer() {
        cancellable?.cancel()
        
        cancellable = Just(())
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink {
                Task.detached(priority: .background) {
                    // TODO: - 좋아요 개수 업데이트 로직 추가
                }
            }
    }
}

#Preview {
    ParentAlbumDetailView(photo: Photo.mock)
        .injectDIContainer()
        .preferredColorScheme(.dark)
}
