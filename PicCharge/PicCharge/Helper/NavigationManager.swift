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
    case childMain(user: UserForSwiftData)
    case childCamera
    case childSendCamera(imageData: Data)
    case childSendGallery
    case childAlbum(user: UserForSwiftData)
    case childAlbumDetail(photo: PhotoForSwiftData)
    
    // MARK: - 부모
    case parentAlbum(user: UserForSwiftData)
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
        case .childMain(let user):
            ChildMainView(user: user)
        case .childCamera:
            ChildCameraView()
        case .childSendCamera(let imageData):
            ChildSendCameraView(imageData: imageData)
        case .childSendGallery:
            ChildSendGalleryView()
        case .childAlbum(let user):
            ChildAlbumView(user: user)
        case .childAlbumDetail(let photo):
            ChildAlbumDetailView(photo: photo)
            
        // MARK: - 부모
        case .parentAlbum(let user):
            ParentAlbumView(user: user)
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
    var userState: UserState {
        willSet {
            prevUserState = userState
        }
    }
    @ObservationIgnored var prevUserState: UserState
    
    init(
        path: [PathType] = [],
        userState: UserState = .checkNeeded,
        prevUserState: UserState = .checkNeeded
    ) {
        self.path = path
        self.userState = userState
        self.prevUserState = userState
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
    
    func isPrevState(_ state: UserState) -> Bool {
        return state == prevUserState
    }
}

