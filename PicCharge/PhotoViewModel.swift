//
//  PhotoViewModel.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI

@Observable
final class PhotoViewModel {
    struct State {
        
    }
    
    private(set) var state: State = .init()
    
    @ObservationIgnored
    private let localStorageService: LocalDataRepository
    
    @ObservationIgnored
    private let remoteStorageService: RemoteStorageService
    
    init(
        localStorageService: LocalDataRepository,
        remoteStorageService: RemoteStorageService
    ) {
        self.localStorageService = localStorageService
        self.remoteStorageService = remoteStorageService
    }
}
