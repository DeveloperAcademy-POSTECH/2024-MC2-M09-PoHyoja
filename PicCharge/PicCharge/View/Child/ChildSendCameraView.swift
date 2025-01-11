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
                        isChildLoadingView = true
                        Task.detached {
                            do {
                                // 1. 사진 업로드
                                try await uploadPhoto()
                                // 2. 위젯 리로드
                                WidgetCenter.shared.reloadAllTimelines()
                                // 3. 화면 이동
                                await MainActor.run { navigationManager.popToRoot() }
                            } catch {
                                // 4. 에러 처리
                                await MainActor.run { isChildLoadingView = false }
                                await GlobalAlert.shared.show(message: error.localizedDescription)
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
    func uploadPhoto() async throws {
        guard let user = userVM.user else { return }
        
        try await photoVM.uploadPhoto(of: user, imgData: imgData)
    }
}

#Preview {
    ChildSendCameraView(imgData: UIImage(resource: .logoLarge).pngData()!)
        .injectDIContainer()
        .preferredColorScheme(.dark)
}
