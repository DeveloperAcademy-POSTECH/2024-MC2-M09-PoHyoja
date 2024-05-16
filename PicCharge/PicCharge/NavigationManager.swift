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
    case childSelectGallery
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

@Observable
class NavigationManager {
    var path: [PathType]
    
    init(path: [PathType] = []) {
        self.path = path
    }
}

