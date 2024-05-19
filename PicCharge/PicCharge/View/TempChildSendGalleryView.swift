//
//  TempChildSendGallery.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/18/24.
//

import SwiftUI
import PhotosUI

struct TempChildSendGalleryView: View {
    @Binding var imageData: Data?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // 일단 Temp파일로서, NavigationStack으로 사용
        VStack {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 360, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 21))
                    .clipped()
            } else {
                Text("No image selected")
                    .padding()
            }
        }
        //.navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("다시 선택하기") {
                    dismiss()
                }
                .foregroundStyle(.white)
                Button("사진 보내기") {
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    TempChildSendGalleryView(imageData: .constant(nil))
}

