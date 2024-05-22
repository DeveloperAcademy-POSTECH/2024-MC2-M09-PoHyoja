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
                    navigationManager.pop()
                } label: {
                    Text("다시 찍기")
                        .foregroundColor(.white)
                }
                
                Button {
                    navigationManager.push(to: .childLoading)
                } label: {
                    Text("사진 보내기")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
