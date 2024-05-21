//
//  TempChildSendCameraView.swift
//  PicCharge
//
//  Created by Jongmin on 5/19/24.
//

import SwiftUI

struct TempChildSendCameraView: View {
    @Binding var image: Image?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                Spacer()
                
                Group {
                    if let image = image {
                        image
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
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("다시 찍기")
                        .foregroundColor(.white)
                }
                
                Button {
                    //MARK: - NavigationPath 사용 시 사진 전송 후, path에 .childMain 를 추가해야합니다.
                } label: {
                    Text("사진 보내기")
                        .foregroundColor(.green) // 다크 모드 컬러 지정 필요
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct TempChildSendCameraView_Previews: PreviewProvider {
    static var previews: some View {
        TempChildSendCameraView(image: .constant(nil))
    }
}
