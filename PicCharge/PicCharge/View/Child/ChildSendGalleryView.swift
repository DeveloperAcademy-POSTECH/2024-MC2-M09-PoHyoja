//
//  ChildSendGalleryView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ChildSendGalleryView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    @Environment(PhotoViewModel.self) var photoVM

    @State private var selectedImgData: Data?
    @State private var isPresented: Bool = false
    @State private var isChildLoadingView: Bool = false
    
    var body: some View {
        if isChildLoadingView {
            ChildLoadingView()
        } else {
            GeometryReader { gr in
                VStack {
                    Spacer()
                    
                    Group {
                        if let imgData = selectedImgData,
                           let uiImage = UIImage(data: imgData)
                        {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                Color.bgGray6
                                
                                Icon.addPhoto
                                    .font(.largeTitle)
                            }
                        }
                    }
                    .frame(
                        width: max(0, gr.size.width - 32),
                        height: max(0, gr.size.width - 32)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 21))
                    .onTapGesture {
                        isPresented = true
                    }
                    
                    Spacer(minLength: 236)
                }
                .padding(.horizontal, 16)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        navigationManager.pop()
                    } label: {
                        Icon.close
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                            .foregroundStyle(.txtPrimaryDark)}
                    }
                    
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("다시 선택하기") {
                        isPresented = true
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
            .sheet(isPresented: $isPresented) {
                ChildSelectGalleryView(selectedImgData: $selectedImgData)
                    .ignoresSafeArea()
            }
            .onAppear {
                isPresented = true
            }
        }
    }
}

extension ChildSendGalleryView {
    func sendPhoto() async throws {
        guard let user = userVM.user,
              let imgData = selectedImgData
        else { return }
        
        let photo = Photo(of: user, imgData: imgData)
        
        try await photoVM.addPhoto(of: user.name, photo: photo)
    }
}

#Preview {
    ChildSendGalleryView()
        .injectDIContainer()
        .preferredColorScheme(.dark)
}
