//
//  ChildAlbumDetailView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData

struct ChildAlbumDetailView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    @Bindable var photo: PhotoForSwiftData
    @State private var isShowingDeleteSheet: Bool = false
    @State private var isShowingInquirySheet: Bool = false
    @State private var isZooming: Bool = false
    
    private let photoForShare: PhotoForShare
    
    init(photo: PhotoForSwiftData) {
        self.photo = photo
        self.photoForShare = PhotoForShare(imgData: photo.imgData, uploadDate: photo.uploadDate)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                Spacer()
                
                if let uiImg = UIImage(data: photo.imgData) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .zoomable(isZooming: $isZooming)
                } else {
                    Color.bgGray
                        .frame(width: geometry.size.width, height: geometry.size.width)
                }
                
                VStack(spacing: 8) {
                    Button { } label: {
                        Icon.heart
                            .font(.system(size: 50))
                            .foregroundColor(.grpRed)
                    }
                    .disabled(true)
                    
                    Text(photo.likeCount == 0 ? " " : "\(photo.likeCount)개")
                        .font(.body)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                .padding(.vertical, 80)
                .opacity(isZooming ? 0 : 1)
            }
            Spacer()
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
}

#Preview {
    ChildAlbumDetailView(photo: PhotoForSwiftData(uploadBy: "", sharedWith: [], imgData: UIImage(systemName: "camera")!.pngData()!))
        .environment(NavigationManager())
}

