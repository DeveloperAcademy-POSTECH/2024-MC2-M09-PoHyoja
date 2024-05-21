//
//  ParentAlbumDetailView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ParentAlbumDetailView: View {
    @State private var imgData: Data
    @State private var likeCount: Int
    @State private var isShowingDeleteSheet: Bool = false
    @State private var isShowingInquirySheet: Bool = false
    
    private let photo: Photo
    
    init(photo: Photo, imgData: Data) {
        self.photo = photo
        self.imgData = imgData
        self.likeCount = photo.likeCount
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                Spacer()
                
                if let uiImg = UIImage(data: imgData) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                } else {
                    Color.bgGray
                        .frame(width: geometry.size.width, height: geometry.size.width)
                }
                
                VStack(spacing: 8) {
                    Button {
                        // MARK: -  좋아요 숫자 누른 경우 통신
                        likeCount += 1
                    } label: {
                        Icon.heart
                            .font(.system(size: 50))
                            .foregroundColor(.grpRed)
                    }
                    
                    Text(likeCount == 0 ? " " : "\(likeCount)개")
                        .font(.body)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                .padding(.vertical, 80)
            }
            Spacer()
        }
        .navigationTitle(photo.uploadDate.toKR())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Button {
                    self.isShowingInquirySheet = true
                } label: {
                    Icon.inquiry
                    Text("문의하기")
                }
                
                ShareLink(item: imgData, preview: SharePreview(
                    "공유하기",
                    image: imgData
                    )
                )
                
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
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    ParentAlbumDetailView(
        photo: Photo(id: UUID(), uploadBy: "", uploadDate: Date(), urlString: "", likeCount: 0),
        imgData: Data()
    )
}
