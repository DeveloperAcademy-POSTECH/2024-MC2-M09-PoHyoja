//
//  UserViewModel.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI

@Observable
final class UserViewModel {
    private(set) var user: User? = .init(name: "자식", role: .child, email: "child@test.com", connectedTo: ["부모"], uploadCycle: 3)
    
    @ObservationIgnored
    private let localStorageService: LocalStorageService
    
    @ObservationIgnored
    private let remoteStorageService: RemoteStorageService
    
    init(
        localStorageService: LocalStorageService,
        remoteStorageService: RemoteStorageService
    ) {
        self.localStorageService = localStorageService
        self.remoteStorageService = remoteStorageService
    }
}
