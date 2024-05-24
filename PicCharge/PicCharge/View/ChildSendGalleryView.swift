//
//  ChildSendGalleryView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
struct ChildSendGalleryView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(\.modelContext) var modelContext
    @Query var userForSwiftDatas: [UserForSwiftData]

    @State private var selectedImageData: Data?
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
                        if let imgData = selectedImageData,
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
                        guard let imageData = selectedImageData else { return }
                        guard let user = userForSwiftDatas.first else {
                            print("UserForSwiftData 에서 정보 불러오기 실패")
                            return
                        }
                        let photoForSwiftData = PhotoForSwiftData(uploadBy: user.name, sharedWith: user.connectedTo, imgData: imageData)
                        
                        // MARK: - 로컬에 이미지 저장
                        modelContext.insert(photoForSwiftData)
                        
                        // MARK: - 사진 전송 로직 imageData: Data를 서버로 전송
                        Task {
                            await FirestoreService.shared.uploadPhoto(userName: user.name, photoForSwiftData: photoForSwiftData)
                        }
                        isChildLoadingView = true
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                ChildSelectGalleryView(selectedImageData: $selectedImageData)
                    .ignoresSafeArea()
            }
            .onAppear {
                isPresented = true
            }
        }
    }
}

#Preview {
    ChildSendGalleryView()
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
