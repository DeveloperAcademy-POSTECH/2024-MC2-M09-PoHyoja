//
//  NavigationManager.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

enum PathType: Hashable {
    // MARK: - 초기 설정
    case mainLogin
    case emailLogin
    case signUpEmailPw
    case signUpName(email: String, password: String, name: String)
    case signUpRole(name: String, email: String, password: String)
    
    // MARK: - 자식
    case childCamera
    case childSendCamera(imgData: Data)
    case childSendGallery
    case childAlbumDetail(photo: Photo)
    
    // MARK: - 부모
    case parentAlbum
    case parentAlbumDetail(photo: Photo)
    
    // MARK: - Setting
    case setting
    
    // MARK: - Temp 플로우
    case tempSignUpName
    case tempSelectFamily
    case tempInvitationCodeInput
    case tempCreateRoom
    case tempJoinRoom
}

extension PathType {
    @ViewBuilder
    func NavigatingView() -> some View {
        switch self {
            // MARK: - 초기 설정
        case .mainLogin:
            MainLoginView()
        case .emailLogin:
            EmailLoginView()
        case .signUpEmailPw:
            SignUpEmailPasswordView()
        case .signUpName(let email, let password, let name):
            SignUpNameView(email: email, password: password, name: name)
        case .signUpRole(let name, let email, let password):
            SignUpRoleView(name: name, email: email, password: password)
            
            // MARK: - 자식
        case .childCamera:
            ChildCameraView()
        case .childSendCamera(let imgData):
            ChildSendCameraView(imgData: imgData)
        case .childSendGallery:
            ChildSendGalleryView()
        case .childAlbumDetail(let photo):
            ChildAlbumDetailView(photo: photo)
            
            // MARK: - 부모
        case .parentAlbum:
            ParentAlbumView()
        case .parentAlbumDetail(let photo):
            ParentAlbumDetailView(photo: photo)
            
            // MARK: - Setting
        case .setting:
            SettingView()
            
            // MARK: - Temp 플로우
        case .tempSignUpName:
            TempSignUpNameView()
        case .tempSelectFamily:
            TempSelectFamilyView()
        case .tempInvitationCodeInput:
            TempInvitationCodeInputView()
        case .tempCreateRoom:
            TempCreateRoomView()
        case .tempJoinRoom:
            TempJoinRoomView()
        }
    }
}

@Observable
class NavigationManager {
    static let shared = NavigationManager()
    
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
        _ = path.popLast()
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    func pop(to pathType: PathType) {
        guard let lastIndex = path.lastIndex(of: pathType) else { return }
        path.removeLast(path.count - (lastIndex + 1))
    }
}

