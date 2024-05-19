//
//  TempChildSendGallery.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/18/24.
//

import SwiftUI
import PhotosUI

struct TempChildSendGalleryView: View {
    let imageData: Data
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 360, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 21))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("다시 선택하기") {
                    // MARK: 다른 로직 필요, - NavigationPath 적용전 이전 뷰로 돌아가기 위한 dismiss()입니다.
                    dismiss()
                }
                .foregroundStyle(.white)
                Button("사진 보내기") {
                    // MARK: NavigationPath 사용 시 로딩뷰로 넘어가야 합니다.
                }
            }
        }
    }
}
