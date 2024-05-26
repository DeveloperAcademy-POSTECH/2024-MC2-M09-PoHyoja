//
//  NavigationManager.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

enum PathType: Hashable {
    // MARK: - 초기 설정
    case signUp
    case selectRole(name: String, email: String, password: String)
    
    // MARK: - 자식
    case childMain
    case childCamera
    case childSendCamera(imageData: Data)
    case childSendGallery
    case childAlbum
    case childAlbumDetail(photo: PhotoForSwiftData)
    
    // MARK: - 부모
    case parentAlbum
    case parentAlbumDetail(photo: PhotoForSwiftData)
    
    // MARK: - Setting
    case setting(role: Role)
    case settingTermsOfUse
}

extension PathType {
    @ViewBuilder
    func NavigatingView() -> some View {
        switch self {
        // MARK: - 초기 설정
        case .signUp:
            UserInfoForSignUpView()
        case .selectRole(let name, let email, let password):
            SelectRoleForSignUpView(name: name, email: email, password: password)
            
        // MARK: - 자식
        case .childMain:
            ChildMainView()
        case .childCamera:
            ChildCameraView()
        case .childSendCamera(let imageData):
            ChildSendCameraView(imageData: imageData)
        case .childSendGallery:
            ChildSendGalleryView()
        case .childAlbum:
            ChildAlbumView()
        case .childAlbumDetail(let photo):
            ChildAlbumDetailView(photo: photo)
            
        // MARK: - 부모
        case .parentAlbum:
            ParentAlbumView()
        case .parentAlbumDetail(let photo):
            ParentAlbumDetailView(photo: photo)
            
        // MARK: - Setting
        case .setting(let role):
            SettingView(myRole: role)
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

