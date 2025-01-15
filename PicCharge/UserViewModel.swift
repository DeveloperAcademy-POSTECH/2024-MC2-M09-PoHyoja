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
    
    func signIn(with email: String, password: String) async {
        do {
            // 1. Auth 이메일 로그인
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // 2. 원격 이메일 유저 확인
            guard let user = try await remoteStorageService.fetchUserByEmail(email) else {
                
                // 3. 발견되지 않을 시 로그아웃
                try Auth.auth().signOut()
                return
            }
            
            // 3. 로컬 유저 저장
            try await localStorageService.addUser(user)
            
            // 4. VM State 업데이트
            await MainActor.run {
                self.user = user
                self.state = user.isConnected ? .connected(user.role) : .notConnected
            }
            
        } catch let error as AuthErrorCode {
            switch error.code {
            case .invalidEmail, .wrongPassword:
                await GlobalAlert.shared.show(message: "이메일과 비밀번호를 확인해주세요!")
            
            case .invalidCredential:
                await GlobalAlert.shared.show(message: "존재하지 않는 이메일입니다.")
                
            default:
                await GlobalAlert.shared.show(message: "\(error.localizedDescription)")
            }
        } catch {
            await GlobalAlert.shared.show(message: "\(error.localizedDescription)")
        }
    }
    
    func checkNameAvailable(name: String) async -> Bool {
        do {
            // 1. 기존 유저 존재 여부 확인
            if let _ = try await remoteStorageService.fetchUserByName(name) {
                await GlobalAlert.shared.show(message: "이미 존재하는 이름입니다.")
                return false
            }
            
            return true
            
        } catch {
            await GlobalAlert.shared.show(message: "\(error.localizedDescription)")
        }
        
        return false
    }
    
    func checkEmailAvailable(email: String) async -> Bool {
        do {
            // 1. 기존 유저 존재 여부 확인
            if let _ = try await remoteStorageService.fetchUserByEmail(email) {
                await GlobalAlert.shared.show(message: "이미 존재하는 이메일입니다.")
                return false
            }
            
            return true
            
        } catch {
            await GlobalAlert.shared.show(message: "\(error.localizedDescription)")
        }
        
        return false
    }
    
    func signUp(name: String, email: String, password: String, role: Role) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let user = User(name: name, role: role, email: email, connectedTo: [])
        
        try await remoteStorageService.addUser(user)
    }
}
