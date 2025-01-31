//
//  DIContainerModifier.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI

struct DIContainerModifier: ViewModifier {
    
    let remoteRepository: RemoteRepository
    let localRepository: LocalRepository
    
    init() {
        remoteRepository = DefaultRemoteRepository()
        localRepository = DefaultLocalRepository()
    }
    
    func body(content: Content) -> some View {
        content
            .environment(
                NavigationManager()
            )
            .environment(
                UserViewModel(
                    localRepository: localRepository,
                    remoteRepository: remoteRepository
                )
            )
            .environment(
                PhotoViewModel(
                    localRepository: localRepository,
                    remoteRepository: remoteRepository
                )
            )
    }
}

extension View {
    func injectDIContainer() -> some View {
        modifier(DIContainerModifier())
    }
}
