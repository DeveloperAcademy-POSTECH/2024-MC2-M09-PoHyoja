//
//  ParentAlbumDetailView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
import Combine

struct ParentAlbumDetailView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(\.modelContext) var modelContext
    
    @Bindable var photo: PhotoForSwiftData
    @State private var isShowingDeleteSheet: Bool = false
    @State private var isShowingInquirySheet: Bool = false
    @State private var isZooming: Bool = false
    @State private var isLiked: Bool = false
    @State private var cancellable: AnyCancellable?
    @State private var likeAnimationIDs: [UUID] = []
    
    private let imageView: Image
    private let photoForShare: PhotoForShare
    
    init(photo: PhotoForSwiftData) {
        self.photo = photo
        self.photoForShare = PhotoForShare(imgData: photo.imgData, uploadDate: photo.uploadDate)
        self.imageView = Image(uiImage: UIImage(data: photo.imgData)!)
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
            
            ForEach(likeAnimationIDs, id: \.self) { id in
                LottieView(jsonName: "LikeAnimation", loopMode: .playOnce)
                    .transition(.opacity)
                    .opacity(0.5)
                    .frame(width: 160, height: 240)
                    .offset(y: 150)
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
                        likeCount += 1
                        let likeID = UUID()
                        likeAnimationIDs.append(likeID)
                        self.resetTimer()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isLiked = false
                        }
                        
                    } label: {
                        Icon.heart
                            .font(.system(size: 50))
                            .foregroundColor(.grpRed)
                    }
                    
                    Text(photo.likeCount == 0 ? " " : "\(photo.likeCount)개")
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
                    // MARK: - 로컬 사진 삭제 처리
                    modelContext.delete(photo)
                    
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
                // MARK: - 로컬 사진 삭제 처리
                modelContext.delete(photo)
                
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
        photo: PhotoForSwiftData(uploadBy: "", sharedWith: [], imgData: UIImage(systemName: "camera")!.pngData()!)
    )
    .environment(NavigationManager())
    .preferredColorScheme(.dark)
}
