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
    @Environment(\.modelContext) var modelContext
    
    @Query(
        sort: \PhotoForSwiftData.uploadDate,
        order: .reverse
    ) var photoForSwiftDatas: [PhotoForSwiftData]
    @State var selection: UUID
    @State private var isShowingDeleteSheet: Bool = false
    @State private var isShowingInquirySheet: Bool = false
    @State private var isZooming: Bool = false
    @State private var isLiked: Bool = false
    @State private var cancellable: AnyCancellable?
    @State private var likeAnimationIDs: [UUID] = []
    
    private let photoForShare: PhotoForShare
    
    var photo: PhotoForSwiftData {
        photoForSwiftDatas.first { $0.id == self.selection } ?? .empty()
    }
    
    init(photo: PhotoForSwiftData) {
        self.selection = photo.id
        self.photoForShare = PhotoForShare(imgData: photo.imgData, uploadDate: photo.uploadDate)
    }
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack {
                TabView(selection: $selection) {
                    ForEach(photoForSwiftDatas) { photo in
                        Group {
                            if let uiImg = UIImage(data: photo.imgData) {
                                Image(uiImage: uiImg)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .zoomable(isZooming: $isZooming)
                            } else {
                                Color.bgGray
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                        .tag(photo.id)
                        .padding(.bottom, 166)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.smooth, value: selection)
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
                    
                    // MARK: - 서버 사진 삭제 처리
                    Task {
                        await FirestoreService.shared.deletePhoto(photoId: photo.id.uuidString)
                    }
                    
                    WidgetCenter.shared.reloadAllTimelines()
                    
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
                
                Task {
                    await FirestoreService.shared.deletePhoto(photoId: photo.id.uuidString)
                }
                
                WidgetCenter.shared.reloadAllTimelines()
                
                navigationManager.pop()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onDisappear {
            Task {
                try await FirestoreService.shared.updatePhoto(photoForSwiftData: photo)
            }
        }
    }
    
    private func resetTimer() {
        cancellable?.cancel()
        
        cancellable = Just(())
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink {
                Task {
                    try await FirestoreService.shared.updatePhoto(photoForSwiftData: photo)
                }
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
