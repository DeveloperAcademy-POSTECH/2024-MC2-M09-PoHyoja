//
//  AsyncImageView.swift
//  PicCharge
//
//  Created by 김병훈 on 5/20/24.
//

import SwiftUI

struct AsyncImageView: View {
    @State private var image: UIImage? = nil
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // 이미지 modifier는 여기서
            } else {
                ProgressView()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = URL(string: urlString) else {
            print("Error conver string to URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                self.image = loadedImage
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
}

