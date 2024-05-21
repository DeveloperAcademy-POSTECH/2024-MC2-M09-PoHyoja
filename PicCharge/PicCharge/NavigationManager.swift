//
//  NavigationManager.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

enum PathType: Hashable {
    // MARK: - 초기 설정
    case login
    case selectRole
    case connectUser
    
    // MARK: - 자식
    case childTab
    case childMain
    case childCamera
    case childSendCamera
    case childSendGallery
    case childLoading
    case childAlbum
    case childAlbumDetail
    
    // MARK: - 부모
    case parentAlbum
    case parentAlbumDetail
    
    // MARK: - Setting
    case setting
    case settingTermsOfUse
}

extension PathType {
    @ViewBuilder
    func NavigatingView() -> some View {
        switch self {
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

@Observable
class NavigationManager {
    var path: [PathType]
    
    init(path: [PathType] = []) {
        self.path = path
    }
}

extension NavigationManager {
    func push(to pathType: PathType) {
        path.append(pathType)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    func pop(to pathType: PathType) {
        guard let lastIndex = path.lastIndex(of: pathType) else { return }
        path.removeLast(path.count - (lastIndex + 1))
    }
}

