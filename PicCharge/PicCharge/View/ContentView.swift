//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationManager = NavigationManager()
    
    @State private var role: Role = .child
    @State private var isAutoLogined: Bool = false
    @State private var isRoleSelected: Bool = false
    @State private var isConnected: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack {
                Text("여기는 실제로 보이지 않는 화면입니다.")
                
                Picker("부모자식 역할", selection: $role) {
                    ForEach(Role.allCases, id: \.self) { role in
                        Text("\(role)")
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("자동 로그인 성공", isOn: $isAutoLogined)
                Toggle("역할 선택 완료", isOn: $isRoleSelected)
                Toggle("부모 자식 연결 완료", isOn: $isConnected)
                
                Text("로그인 실패")
                Button("로그인 화면으로 이동") {
                    navigationManager.path.append(.login)
                }
                .disabled(isAutoLogined)
                
                Text("로그인 성공")
                Button("역할선택화면으로 이동") {
                    navigationManager.path.append(.selectRole)
                }
                .disabled(!(isAutoLogined && !isRoleSelected && !isConnected))
                
                Text("로그인 성공 & 역할 선택 완료")
                Button("유저연결화면으로 이동") {
                    navigationManager.path.append(.connectUser)
                }
                .disabled(!(isAutoLogined && isRoleSelected && !isConnected))
                
                Text("로그인 성공 & 역할 선택 완료 & 연결 완료")
                Button("\(role) 메인화면으로 이동") {
                    navigationManager.path.append(role == .child ? .childTab : .parentAlbum)
                }
                .disabled(!(isAutoLogined && isRoleSelected && isConnected))
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
