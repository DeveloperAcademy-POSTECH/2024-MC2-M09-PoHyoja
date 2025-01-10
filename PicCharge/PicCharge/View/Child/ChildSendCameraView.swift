//
//  ChildSendCameraView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ChildSendCameraView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    @Environment(PhotoViewModel.self) var photoVM
    
    @State private var isChildLoadingView: Bool = false
    private let imgData: Data
    
    init(imgData: Data) {
        self.imgData = imgData
    }
    
    var body: some View {
        if isChildLoadingView {
            ChildLoadingView()
        } else {
            GeometryReader { gr in
                VStack {
                    Spacer()
                    
                    Group {
                        if let uiImage = UIImage(data: imgData) {
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
                        Task {
                            isChildLoadingView = true
                            do {
                                // 1. 사진 업로드
                                try await sendPhoto()
                                // 2. 위젯 리로드
                                WidgetCenter.shared.reloadAllTimelines()
                                // 3. 화면 이동
                                navigationManager.popToRoot()
                            } catch {
                                // Fail: 사진 업로드 실패
                                isChildLoadingView = false
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

extension ChildSendCameraView {
    func sendPhoto() async throws {
        guard let user = userVM.user else { return }
        
        let photo = Photo(of: user, imgData: imgData)
        
        try await photoVM.addPhoto(of: user.name, photo: photo)
    }
}

#Preview {
    ChildSendCameraView(imgData: UIImage(resource: .logoLarge).pngData()!)
        .injectDIContainer()
        .preferredColorScheme(.dark)
}
