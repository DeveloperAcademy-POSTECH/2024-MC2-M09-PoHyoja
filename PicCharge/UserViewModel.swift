//
//  UserViewModel.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
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
    var state: State = .checkNeeded
    private(set) var nounce: String = ""
    
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
    
    func logOut() async throws {
        guard let user else { return }
        
        try Auth.auth().signOut()
        try await localStorageService.deleteUser(user.name)
        try await localStorageService.deleteAllPhotos()
        
        print("-- 로컬 데이터 삭제 --")
        
        await MainActor.run {
            self.user = nil
            self.state = .notExist
        }
    }
    
    func signOut() async throws {
        //TODO: 현재는 탈퇴하기 눌러도 로그아웃 처리, 추후 탈퇴기능 논의
        try await logOut()
    }
    
    
}

extension UserViewModel {
    func addConnections(with otherUser: User) async throws {
        guard let user else { return }
        
        try await remoteStorageService.updateConnections(of: user, with: [otherUser.name])
        try await remoteStorageService.updateConnections(of: otherUser, with: [user.name])
        
        try await addLocalConnections(with: otherUser.name)
        
        await MainActor.run { self.user?.connectedTo += [otherUser.name] }
    }
    
    func addLocalConnections(with userName: String) async throws {
        guard let user else { return }
        
        try await localStorageService.addConnection(of: user, with: [])
        
        await MainActor.run { self.user?.connectedTo += [userName] }
    }
}

// Apple Login에 필요한 기능 구현
extension UserViewModel {

    // Apple 로그인 시작
    func configureAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        self.nounce = randomNonceString()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nounce)
    }
    
    // Nonce 생성
    func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    // SHA256 해싱
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func processAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                do {
                    try await performFirebaseSignIn(with: credential) // Apple Credential로 Firebase 인증 처리
                } catch {
                    print("Apple Sign-In 처리 실패: \(error.localizedDescription)")
                }
            } else {
                print("Apple Sign-In 실패: Credential 변환 실패")
            }
        case .failure(let error):
            print("Apple Sign-In 에러: \(error.localizedDescription)")
        }
    }

    // Apple Credential을 사용해 Firebase 인증 처리
    func performFirebaseSignIn(with credential: ASAuthorizationAppleIDCredential) async throws {
        // 1. Apple에서 제공한 identityToken을 가져와 Firebase 인증에 사용
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token"])
        }

        // 2. Firebase 인증을 위한 Credential 생성
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: nounce
        )

        do {
            // 3. Firebase 인증 요청
            let authResult = try await Auth.auth().signIn(with: firebaseCredential)

            // 4. Firebase 인증 성공 시 사용자 정보 디버깅 출력
            print("Firebase Auth 성공: \(authResult.user.email ?? "Unknown email")")

            // TODO: Firestore에서 사용자 정보 확인 및 로컬 데이터 저장 추가 가능
        } catch {
            print("Firebase Auth 실패: \(error.localizedDescription)")
            throw error
        }
    }
}
