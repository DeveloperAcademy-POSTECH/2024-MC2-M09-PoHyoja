//
//  UserViewModel.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI
import FirebaseAuth

@Observable
final class UserViewModel {
    enum State: Equatable {
        case checkNeeded
        case notExist
        case notConnected
        case connected(Role)
    }
    
    private(set) var user: User?
    private(set) var state: State = .checkNeeded
    
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
    
    func checkUserState() async {
        // 1. Local User 확인
        guard let user = await localStorageService.fetchUser() else {
            await MainActor.run { self.state = .notExist }
            return
        }
        
        // 2. Auth 로그인 여부 확인
        guard let _ = Auth.auth().currentUser else {
            
            // 2-1. Auth 미로그인 시 로컬 유저 정보 삭제
            // 에러 발생 여부 무시 - Auth 미인증 시 다시 막힘!
            try? await localStorageService.deleteUser(user.name)

            await MainActor.run { self.state = .notExist }
            return
        }
        
        // 3. 부모 자식 연결 여부 확인
        guard !user.connectedTo.isEmpty else {
            await MainActor.run {
                self.user = user
                self.state = .notConnected
            }
            return
        }
        
        print("--swiftDataUser 정보--")
        print("name: \(user.name)")
        print("role: \(user.role)")
        print("email: \(user.email)")
        print("connectedTo: \(user.connectedTo)")
        print("uploadCycle: \(user.uploadCycle ?? 0)")
        print("유저정보 확인: \(user.role) 역할")
        
        await MainActor.run {
            self.user = user
            self.state = .connected(user.role)
        }
    }
}
