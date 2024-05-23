//
//  ChildSendCameraView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData

struct ChildSendCameraView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(\.modelContext) var modelContext
    
    @State private var isChildLoadingView: Bool = false
    private let imageData: Data
    
    init(imageData: Data) {
        self.imageData = imageData
    }
    
    var body: some View {
        if isChildLoadingView {
            ChildLoadingView()
        } else {
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
                    Button("다시 찍기") {
                        navigationManager.pop()
                    }
                    .foregroundStyle(.txtPrimaryDark)
                    
                    Button("사진 보내기") {
                        // MARK: - 로컬에 이미지 저장
                        // TODO: - 유저 정보 주입
                        modelContext.insert(PhotoForSwiftData(uploadBy: "", sharedWith: [], imgData: imageData))
                        
                        // TODO: - 사진 전송 로직 imageData: Data를 서버로 전송
                        
                        isChildLoadingView = true
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
