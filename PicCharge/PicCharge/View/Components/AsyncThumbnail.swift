//
//  AsyncThumbnail.swift
//  PicCharge
//
//  Created by 남유성 on 2/12/25.
//

import SwiftUI

struct AsyncThumbnail: View {
    @Environment(PhotoViewModel.self) var photoVM
    @State private var uiImage: UIImage?
    private let photo: Photo
    private var photoId: String { photo.id.uuidString + "_thumb" }

    init(photo: Photo) {
        self.photo = photo
    }

    var body: some View {
        if let uiImage {
            Image(uiImage: uiImage)
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
                await MainActor.run { self.uiImage = cachedImage }
                return
            }

            if let downsampledImage = imgData.downsampling(to: CGSize(width: 100, height: 100)) {

                await MainActor.run { self.uiImage = downsampledImage }
                await ImageCache.shared.insertImage(downsampledImage, for: photoId)
            }
        }
    }

    private func loadImage() async {
        guard let urlString = photo.urlString else { return }

        do {
            let data = try await photoVM.downloadPhoto(of: urlString)

            await MainActor.run { self.uiImage = UIImage(data: data) }
            
            self.photo.imgData = data
            try await photoVM.updateLocal(of: photo)

        } catch {
            print("Error loading image: \(error)")
        }
    }
}


#Preview {
    AsyncThumbnail(photo: .onlyUrlMock1)
        .injectPreviewDIContainer(user: .childMock, photos: [.onlyUrlMock1])
}
