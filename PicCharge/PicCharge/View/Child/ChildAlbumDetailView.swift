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
    @Environment(\.modelContext) var modelContext

    @State private var photoForSwiftDatas: [PhotoForSwiftData] = []
    @State private var photo: PhotoForSwiftData
    @State private var isShowingDeleteSheet: Bool = false
    @State private var isZooming: Bool = false
    
    private var photoForShare: PhotoForShare {
        PhotoForShare(imgData: photo.imgData, uploadDate: photo.uploadDate)
    }
    
    init(photo: PhotoForSwiftData) {
        self.photo = photo
    }
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack {
                TabView(selection: $photo) {
                    ForEach(photoForSwiftDatas) { photo in
                        ImageView(image: photo.imgData)
                            .zoomable(isZooming: $isZooming)
                            .tag(photo)
                            .padding(.bottom, 166)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
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
        .task {
            photoForSwiftDatas = await getPhotos()
        }
    }
    
    func getPhotos() async -> [PhotoForSwiftData] {
        let descriptor = FetchDescriptor<PhotoForSwiftData>(sortBy: [SortDescriptor(\.uploadDate, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

extension ChildAlbumDetailView {
    struct ImageView: View {
        let image: Data
        
        var body: some View {
            if let uiImg = UIImage(data: image) {
                Image(uiImage: uiImg)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Color.bgGray
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

#Preview {
    ChildAlbumDetailView(photo: PhotoForSwiftData(uploadBy: "", sharedWith: [], imgData: UIImage(systemName: "camera")!.pngData()!))
        .environment(NavigationManager())
}
