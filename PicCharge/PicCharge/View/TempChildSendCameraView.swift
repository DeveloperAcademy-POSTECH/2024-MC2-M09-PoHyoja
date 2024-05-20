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
        VStack {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .cornerRadius(21)
                    .padding()
                // CameraPreview와 같은 선상에 배치하기 위한 값
                    .offset(y: -72)
            }
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
