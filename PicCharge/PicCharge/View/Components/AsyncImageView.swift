//
//  AsyncImageView.swift
//  PicCharge
//
//  Created by 남유성 on 5/21/24.
//

import SwiftUI

struct AsyncImageView: View {
    @State private var imgData: Data? = nil
    private let urlString: String
    private var didTapImageView: ((Data) -> ())?
    
    init(urlString: String, didTapImageView: ((Data) -> ())? = nil) {
        self.urlString = urlString
        self.didTapImageView = didTapImageView
    }

    var body: some View {
        Group {
            if let imgData = imgData,
               let image = UIImage(data: imgData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .onTapGesture {
                        didTapImageView?(imgData)
                    }
                
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
            guard UIImage(data: data) != nil else { return }
            self.imgData = data
        } catch {
            print("Error loading image: \(error)")
        }
    }
}
#Preview {
    AsyncImageView(
        urlString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsNICnidsWi7x-UmXHlkEz-8VUeKwmJSg86Xli4i-26A&s",
        didTapImageView: { _ in }
    )
}
