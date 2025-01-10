//
//  SquareImage.swift
//  PicCharge
//
//  Created by 남유성 on 1/9/25.
//

import SwiftUI

struct SquareImage: View {
    let data: Data?
    
    init(data: Data? = nil) {
        self.data = data
    }
    
    var body: some View {
        if let data,
           let uiImage = UIImage(data: data) {
            
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
            
        } else {
            Color.bgGray
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

#Preview {
    VStack {
        SquareImage(data: UIImage(resource: .logoLarge).pngData())
        SquareImage()
    }
}
