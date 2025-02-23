//
//  AsyncSquareImage.swift
//  PicCharge
//
//  Created by 남유성 on 1/22/25.
//

import SwiftUI

struct AsyncSquareImage: View {
    @Environment(PhotoViewModel.self) var photoVM
    @State private var cache: (id: UUID, image: UIImage)?
    
    private let photo: Photo
    private let size: CGSize
    private var photoId: String { photo.id.uuidString + "_\(size.width)"}
    
    init(photo: Photo, size: CGSize = .main) {
        self.photo = photo
        self.size = size
    }
    
    var body: some View {
        if let cache, (cache.id == photo.id) {
            Image(uiImage: cache.image)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
            
        } else {
            
            Color.bgGray
                .aspectRatio(1, contentMode: .fit)
                .overlay { ProgressView() }
                .task {
                    if let imgData = photo.imgData {
                        await loadCache(imgData: imgData)
                    } else {
                        await loadImage()
                    }
                }
        }
    }
    
    private func loadCache(imgData: Data) async {
        Task.detached {
            if let cachedImage = await ImageCache.shared.image(for: photoId) {
                await MainActor.run { self.cache = (id: photo.id, image: cachedImage) }
                return
            }

            if let downsampledImage = imgData.downsampling(to: size) {
                await MainActor.run { self.cache = (id: photo.id, image: downsampledImage) }
                await ImageCache.shared.insertImage(downsampledImage, for: photoId)
            }
        }
    }
    
    private func loadImage() async {
        guard let urlString = photo.urlString else { return }

        do {
            // Firebase에서 이미지 다운로드
            let data = try await photoVM.downloadPhoto(of: urlString)
            let downSampledImage = data.downsampling(to: size)
            
            await MainActor.run {
                self.cache = (id: photo.id, image: downSampledImage!)
            }
            
            // 현재 ViewModel의 원본 사진 업데이트
            self.photo.imgData = data
            // 로컬 저장소에 원본 사진 저장
            try await photoVM.update(of: photo)
            
        } catch {
            print("Error loading image: \(error)")
        }
    }
}

#Preview {
    AsyncSquareImage(photo: .onlyUrlMock1, size: .main)
        .injectPreviewDIContainer(user: .childMock, photos: [.onlyUrlMock1])
    
    AsyncSquareImage(photo: .withDataMock1, size: .main)
        .injectPreviewDIContainer(user: .childMock, photos: [.withDataMock1])
}
