//
//  DIContainerModifier.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI

struct DIContainerModifier: ViewModifier {
    
    let remoteStorageService: RemoteStorageService
    let localStorageService: LocalStorageService
    
    init() {
        remoteStorageService = FireStoreRepository(fireStore: .firestore(), storage: .storage())
        localStorageService = SwiftDataRepository(isMemoryOnly: true)
    }
    
    func body(content: Content) -> some View {
        content
            .environment(
                NavigationManager()
            )
            .environment(
                UserViewModel(
                    localStorageService: localStorageService,
                    remoteStorageService: remoteStorageService
                )
            )
            .environment(
                PhotoViewModel(
                    localStorageService: localStorageService,
                    remoteStorageService: remoteStorageService
                )
            )
    }
}

extension View {
    func injectDIContainer() -> some View {
        modifier(DIContainerModifier())
    }
}
