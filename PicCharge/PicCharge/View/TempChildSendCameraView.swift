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
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Spacer()
            
            VStack {
                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .cornerRadius(21)
                        .padding()
                } else {
                    Color.black
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("다시 찍기")
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // 사진 보내기
                    }) {
                        Text("사진 보내기")
                            .foregroundColor(.green) // 다크 모드 컬러 지정 필요
                            .padding()
                    }
                }
                .padding()
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
