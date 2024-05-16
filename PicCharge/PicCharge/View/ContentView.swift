//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationManager = NavigationManager()
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack {
                // TODO: - 자식 부모 플로우 분리 필요
                Button("로그인 성공 -> 탭화면") {
                    navigationManager.path.append(.childTab)
                }
                
                Button("로그인 실패 -> 로그인화면") {
                    navigationManager.path.append(.login)
                }
            }
            
            .navigationDestination(for: PathType.self) { path in
                switch path {
                    // MARK: - 초기 설정
                case .login:
                    LoginView()
                case .selectRole:
                    SelectRoleView()
                case .connectUser:
                    ConnectUserView()
                    
                    // MARK: - 자식
                case .childTab:
                    ChildTabView()
                case .childMain:
                    ChildMainView()
                case .childCamera:
                    ChildCameraView()
                case .childSendCamera:
                    ChildSendCameraView()
                case .childSelectGallery:
                    ChildSelectGalleryView()
                case .childSendGallery:
                    ChildSendGalleryView()
                case .childLoading:
                    ChildLoadingView()
                case .childAlbum:
                    ChildAlbumView()
                case .childAlbumDetail:
                    ChildAlbumDetailView()
                    
                    // MARK: - 부모
                case .parentAlbum:
                    ParentAlbumView()
                case .parentAlbumDetail:
                    ParentAlbumDetailView()
                    
                    // MARK: - Setting
                case .setting:
                    SettingView()
                case .settingTermsOfUse:
                    SettingTermsOfUseView()
                }
            }
        }
        .environment(navigationManager)
    }
}

#Preview {
    ContentView()
}
