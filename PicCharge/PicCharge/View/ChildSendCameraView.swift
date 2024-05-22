//
//  ChildSendCameraView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildSendCameraView: View {
    @Environment(NavigationManager.self) var navigationManager
    private let imageData: Data

    init(imageData: Data) {
        self.imageData = imageData
    }
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                Spacer()
                
                Group {
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(
                    width: max(0, gr.size.width - 32),
                    height: max(0, gr.size.width - 32)
                )
                .clipShape(RoundedRectangle(cornerRadius: 21))
                
                Spacer(minLength: 236)
            }
            .padding(.horizontal, 16)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    //MARK: - NavigationPath 사용 전 이전 View로 돌아가긴 위한 dismiss()
                    navigationManager.pop()
                } label: {
                    Text("다시 찍기")
                        .foregroundColor(.white)
                }
                
                Button {
                    //MARK: - NavigationPath 사용 시 사진 전송 후, path에 .childMain 를 추가해야합니다.
                    navigationManager.push(to: .childLoading)
                } label: {
                    Text("사진 보내기")
                        .foregroundColor(.green) // 다크 모드 컬러 지정 필요
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    ChildSendCameraView()
//        .environment(NavigationManager())
//}
