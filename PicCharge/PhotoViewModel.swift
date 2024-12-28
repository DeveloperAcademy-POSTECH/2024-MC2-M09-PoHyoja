//
//  PhotoViewModel.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI

final class PhotoViewModel: ObservableObject {
    struct State {
        
    }
    
    @Published private(set) var state: State = .init()
    
    private let localStorageService: LocalStorageService
    private let remoteStorageService: RemoteStorageService
    
    init(
        localStorageService: LocalStorageService,
        remoteStorageService: RemoteStorageService
    ) {
        self.localStorageService = localStorageService
        self.remoteStorageService = remoteStorageService
    }
}
