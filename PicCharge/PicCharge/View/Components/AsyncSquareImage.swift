//
//  AsyncSquareImage.swift
//  PicCharge
//
//  Created by 남유성 on 1/22/25.
//

import SwiftUI

struct AsyncSquareImage: View {
    @Environment(PhotoViewModel.self) var photoVM
    @Bindable var photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
    }
    
    var body: some View {
        if let imgData = photo.imgData,
           let uiImage = UIImage(data: imgData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        } else {
            Color.bgGray
                .aspectRatio(1, contentMode: .fit)
                .overlay { ProgressView() }
                .task {
                    await loadImage()
                }
        }
    }
    
    private func loadImage() async {
        guard let urlString = photo.urlString else { return }

        do {
            let data = try await photoVM.downloadPhoto(of: urlString)
            
            await MainActor.run {
                withAnimation {
                    self.photo.imgData = data
                }
            }
            
            try await photoVM.updateLocal(of: photo)
            
        } catch {
            print("Error loading image: \(error)")
        }
    }
}

#Preview {
    AsyncSquareImage(photo: .onlyUrlMock1)
        .injectPreviewDIContainer(user: .childMock, photos: [.onlyUrlMock1])
    
    AsyncSquareImage(photo: .withDataMock1)
        .injectPreviewDIContainer(user: .childMock, photos: [.withDataMock1])
}
