//
//  ChildAlbumDetailView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
import WidgetKit

// photo는 현재 보고 있는 사진이다.
// 만약 photo가 모두 삭제된다면 해당 페이지에서 나와야한다.

struct ChildAlbumDetailView: View {
    @Environment(NavigationManager.self) var navigationManager
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
        ZStack {
            Color.clear.ignoresSafeArea()
            
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
        .navigationTitle(photo.uploadDate.toKR())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isZooming ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            Menu {
                ShareLink(
                    item: photoForShare,
                    preview: SharePreview(
                        photoForShare.caption,
                        image: photoForShare.image
                    )
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
                photoVM.deletePhoto(photo: photo)
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: photoVM.photos) { oldValue, newValue in
            if photoVM.photos.isEmpty { navigationManager.pop() }
            else {
                guard let index = oldValue.firstIndex(of: photo),
                      0..<newValue.count ~= index
                else { return }

                self.photo = newValue[index]
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChildAlbumDetailView(photo: Photo.mocks.first!)
            .injectDIContainer()
    }
}
