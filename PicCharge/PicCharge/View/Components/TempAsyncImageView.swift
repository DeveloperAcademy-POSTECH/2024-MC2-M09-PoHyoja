//
//  AsyncImageView.swift
//  PicCharge
//
//  Created by 남유성 on 5/21/24.
//

import SwiftUI

struct TempAsyncImageView: View {
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
                    .scaledToFill()
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
            print("Error convert string to URL")
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
#Preview {
    TempAsyncImageView(urlString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsNICnidsWi7x-UmXHlkEz-8VUeKwmJSg86Xli4i-26A&s")
}
