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
    
    @ObservationIgnored private let localRepository: LocalRepository
    @ObservationIgnored private let remoteRepository: RemoteRepository
    @ObservationIgnored private var nounce: String = ""
    @ObservationIgnored var tempAppleFullName: String = ""
    
    init(
        user: User? = nil,
        localRepository: LocalRepository,
        remoteRepository: RemoteRepository
    ) {
        self.user = user
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }
    
    func checkUserState() async {
        // 1. Local User 확인
        guard let user = await localRepository.fetchUser() else {
            print("[checkUserState] 로컬 유저 없음 → state = .notExist")
            await MainActor.run { self.state = .notExist }
            return
        }
        
        // 2. Auth 로그인 여부 확인
        guard let _ = Auth.auth().currentUser else {
            
            // 2-1. Auth 미로그인 시 로컬 유저 정보 삭제
            // 에러 발생 여부 무시 - Auth 미인증 시 다시 막힘!
            try? await localRepository.deleteUser(user.name)

            await MainActor.run { self.state = .notExist }
            return
        }
        
        // 3. 부모 자식 연결 여부 확인
        guard !user.connectedTo.isEmpty else {
            await MainActor.run {
                self.user = user
                self.state = .notConnected
            }
            print("부모자식 연결 안됨: \(self.state)")
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
            guard let user = try await remoteRepository.fetchUserByEmail(email) else {
                
                // 3. 발견되지 않을 시 로그아웃
                try Auth.auth().signOut()
                return
            }
            
            // 3. 로컬 유저 저장
            try await localRepository.addUser(user)
            
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
    
    func signInWithApple() async {
        do {
             // 1. 현재 Firebase Auth 사용자가 존재하는지 확인
             guard let currentUser = Auth.auth().currentUser else {
                 // 아직 Apple Credential로 인증되지 않았거나
                 // Apple 로그인 프로세스가 완료되지 않은 상황
                 print("애플 로그인: 현재 사용자가 존재하지 않음 (Auth)")
                 return
             }
             
             // 2. 이메일 가져오기
             let email = currentUser.email ?? "No email"
             print("애플 로그인 이메일: \(email)")

             // 3. Firestore에서 사용자 정보 확인
             guard let user = try await remoteRepository.fetchUserByEmail(email) else {
                 // Firestore에 사용자 정보가 없다면 -> 회원가입(이름/역할 설정)이 안 된 상태
                 // 애플 로그인만 완료된 상태이므로, 로컬 정보 저장 없이 로그아웃 or 추가 흐름
                 print("애플 로그인: Firestore에 사용자 정보 없음. 회원가입 필요")
                 
                 try Auth.auth().signOut()
                 return
             }
             try await localRepository.addUser(user)
             
             // 4. VM State 업데이트
             await MainActor.run {
                 self.user = user
                 self.state = user.isConnected ? .connected(user.role) : .notConnected
             }
             
             print("애플 로그인: Firestore 사용자 정보 확인 완료. State 업데이트.")

         } catch let error as NSError {
             // Apple 로그인 / Firebase Auth 에러 처리
             print("애플 로그인 실패: \(error.localizedDescription)")
             
             // 추가적인 에러 분기 (AuthErrorCode) 필요하다면
             if let authError = AuthErrorCode.Code(rawValue: error.code) {
                 switch authError {
                 case .invalidEmail:
                     await GlobalAlert.shared.show(message: "이메일 형식이 올바르지 않습니다.")
                 case .userDisabled:
                     await GlobalAlert.shared.show(message: "사용할 수 없는 계정입니다.")
                 default:
                     await GlobalAlert.shared.show(message: "애플 로그인 에러: \(error.localizedDescription)")
                 }
             } else {
                 // Firestore 관련 에러 등
                 await GlobalAlert.shared.show(message: "애플 로그인 에러: \(error.localizedDescription)")
             }
         }
    }
    
    func checkNameAvailable(name: String) async -> Bool {
        do {
            // 1. 기존 유저 존재 여부 확인
            if let _ = try await remoteRepository.fetchUserByName(name) {
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
            if let _ = try await remoteRepository.fetchUserByEmail(email) {
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
        
        try await remoteRepository.addUser(user)
    }
    
    func signUpWithApple(name: String, email: String, role: Role) async throws {
        // Firebase Auth에는 이미 계정이 있으므로 Firestore에만 저장
        let user = User(name: name, role: role, email: email, connectedTo: [])
        
        try await remoteRepository.addUser(user)
        try await localRepository.addUser(user)
        
        await MainActor.run {
            self.user = user
            self.state = .notConnected
        }
    }
    
    func logOut() async throws {
        guard let user else { return }
        
        try Auth.auth().signOut()
        try await localRepository.deleteUser(user.name)
        try await localRepository.deleteAllPhotos()
        
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
        
        try await remoteRepository.updateConnections(of: user, with: [otherUser.name])
        try await remoteRepository.updateConnections(of: otherUser, with: [user.name])
        try await addLocalConnections(with: otherUser.name)
    }
    
    func addLocalConnections(with otherUserName: String) async throws {
        guard let user else { return }
        
        try await localRepository.addConnection(of: user, with: [otherUserName])
        await MainActor.run { self.user?.connectedTo += [otherUserName] }
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
    
    func processAppleSignInResult(_ result: Result<ASAuthorization, Error>) async -> (Bool, String)? {
            switch result {
            case .success(let authorization):
                if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    do {
                        let (isNewUser, email, fullName) = try await performAppleFirebaseSignIn(credential: credential)
                        await MainActor.run {
                            self.tempAppleFullName = fullName.isEmpty ? "사용자" : fullName
                            print("[DEBUG] Apple Sign-In tempAppleFullName 저장: \(self.tempAppleFullName)")
                        }
                        
                        return (isNewUser, email)
                    } catch {
                        print("Apple Sign-In 처리 실패: \(error.localizedDescription)")
                        return nil
                    }
                } else {
                    print("Apple Sign-In 실패: Credential 변환 실패")
                    return nil
                }
            case .failure(let error):
                print("Apple Sign-In 에러: \(error.localizedDescription)")
                return nil
            }
        }
    
    private func performAppleFirebaseSignIn(credential: ASAuthorizationAppleIDCredential) async throws -> (Bool, String, String) {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token"])
        }
        
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: nounce
        )
        
        let authResult = try await Auth.auth().signIn(with: firebaseCredential)
        
        guard let email = authResult.user.email else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing email"])
        }
        
        let fullName = credential.fullName?.formatted() ?? ""

        // 5. Firestore 조회하여 기존 유저 여부 판단
        if let existingUser = try await remoteRepository.fetchUserByEmail(email) {
            // 기존 유저 → Firestore에서 저장된 이름 가져오기
            let storedName = existingUser.name
            return (false, email, storedName)
        } else {
            // 신규 유저 → fullName 저장 필요
            return (true, email, fullName)
        }
    }
}
