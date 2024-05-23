//
//  ParentAlbumDetailView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import Combine

struct ParentAlbumDetailView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    @State private var likeCount: Int
    @State private var isShowingDeleteSheet: Bool = false
    @State private var isShowingInquirySheet: Bool = false
    @State private var isZooming: Bool = false
    @State private var isLiked: Bool = false
    @State private var cancellable: AnyCancellable?
    
    private let imageView: Image
    private let photo: Photo
    private let photoForShare: PhotoForShare
    
    init(photo: Photo, imgData: Data) {
        self.photo = photo
        self.imageView = Image(uiImage: UIImage(data: imgData)!)
        self.photoForShare = PhotoForShare(imgData: imgData, uploadDate: photo.uploadDate)
        self.likeCount = photo.likeCount
    }
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack {
                Spacer()
                imageView
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
                    .zoomable(isZooming: $isZooming)
                    .padding(.bottom, 166)
                Spacer()
            }
            
            if isLiked {
                LottieView(jsonName: "TempLikeAnimation", loopMode: .playOnce)
                    .transition(.opacity)
                    .frame(width: 400, height: 600)
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Button {
                        likeCount += 1
                        withAnimation {
                            isLiked = true
                        }
                        self.resetTimer()
                        
                    } label: {
                        Icon.heart
                            .font(.system(size: 50))
                            .foregroundColor(.grpRed)
                    }
                    
                    Text(likeCount == 0 ? " " : "\(likeCount)개")
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
                Button {
                    self.isShowingInquirySheet = true
                } label: {
                    Icon.inquiry
                    Text("문의하기")
                }
                
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
                    // TODO: - 로컬 UI 사진 삭제 처리
                    // TODO: - 서버 사진 삭제 처리
                    navigationManager.pop()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .confirmationDialog(
            "이 사진을 문의하시겠습니까?",
            isPresented: $isShowingInquirySheet,
            titleVisibility: .visible
        ) {
            Button("문의하기") {
                // TODO: - 로컬 UI 사진 삭제 처리
                // TODO: - 서버 사진 삭제 처리
                navigationManager.pop()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func resetTimer() {
        cancellable?.cancel()
        
        cancellable = Just(())
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink {
                withAnimation {
                    self.isLiked = false
                }
                // TODO: - 서버 좋아요 API 호출
            }
    }
}

#Preview {
    ParentAlbumDetailView(
        photo: Photo(id: "", uploadBy: "", uploadDate: Date(), urlString: "", likeCount: 0, sharedWith: []),
        imgData: UIImage(systemName: "camera")!.pngData()!
    )
    .environment(NavigationManager())
    .preferredColorScheme(.dark)
}
