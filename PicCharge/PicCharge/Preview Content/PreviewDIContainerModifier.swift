//
//  PreviewDIContainerModifier.swift
//  PicCharge
//
//  Created by 남유성 on 1/31/25.
//

import SwiftUI

struct PreviewDIContainerModifier: ViewModifier {
    
    let user: User?
    let photos: [Photo]
    let remoteRepository: RemoteRepository
    let localRepository: LocalRepository
    
    init(
        user: User? = nil,
        photos: [Photo] = [],
        localRepository: LocalRepository,
        remoteRepository: RemoteRepository
    ) {
        self.user = user
        self.photos = photos
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }
    
    func body(content: Content) -> some View {
        content
            .globalAlert()
            .environment(
                NavigationManager()
            )
            .environment(
                UserViewModel(
                    user: user,
                    localRepository: localRepository,
                    remoteRepository: remoteRepository
                )
            )
            .environment(
                PhotoViewModel(
                    photos: photos,
                    localRepository: localRepository,
                    remoteRepository: remoteRepository
                )
            )
    }
}

extension View {
    func injectPreviewSetting(user: User,
                              localPhotos: [Photo],
                              remotePhotos: [Photo],
                              response: MockResponseType = .success) -> some View {
        
        modifier(PreviewDIContainerModifier(
            user: user,
            photos: localPhotos,
            localRepository: MockLocalRepository(user: user, photos: localPhotos),
            remoteRepository: MockRemoteRepository(
                users: [user],
                photos: remotePhotos,
                response: response)
        ))
    }
    
    func injectPreviewSetting(user: User?,
                              photos: [Photo] = [],
                              response: MockResponseType = .success) -> some View {
        
        modifier(PreviewDIContainerModifier(
            user: user,
            photos: photos,
            localRepository: MockLocalRepository(user: user, photos: photos),
            remoteRepository: MockRemoteRepository(
                users: user == nil ? [] : [user!],
                photos: photos,
                response: response)
        ))
    }
}

