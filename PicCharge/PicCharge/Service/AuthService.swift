//
//  AuthService.swift
//  PicCharge
//
//  Created by Woowon Kang on 1/8/25.
//

import Firebase
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class AuthService: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var currentNonce: String?
    private var onCompletion: ((Result<AuthDataResult, Error>) -> Void)?
    weak var presentingViewController: UIViewController?

    func startSignInWithApple() async throws -> UserDTO? {
            let nonce = randomNonceString()
            currentNonce = nonce

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.email, .fullName]
            request.nonce = sha256(nonce)

            return try await withCheckedThrowingContinuation { continuation in
                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self
                authorizationController.presentationContextProvider = self

                self.onCompletion = { result in
                    switch result {
                    case .success(let authResult):
                        do {
                            guard let email = authResult.user.email else {
                                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email not found"])
                            }
                            // Firestore에서 사용자 정보 가져오기
                            Task {
                                if let userDTO = await FirestoreService.shared.fetchUserByEmail(email: email) {
                                    // Firestore에 사용자가 있는 경우
                                    continuation.resume(returning: userDTO)
                                }
                            }
                        } catch {
                            print("Apple 로그인 실패: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        print("Apple 로그인 요청 실패: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                }

                authorizationController.performRequests()
            }
        }

    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                onCompletion?(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state"])))
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                onCompletion?(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing identity token"])))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                onCompletion?(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string"])))
                return
            }
            
            let email = appleIDCredential.email ?? "No email provided"
            print("Email: \(email)")
            let fullName = appleIDCredential.fullName
            let firstName = fullName?.givenName ?? "No first name"
            let lastName = fullName?.familyName ?? "No last name"
            print("First Name: \(firstName), Last Name: \(lastName)")

            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: firebaseCredential) { authResult, error in
                if let error = error {
                    self.onCompletion?(.failure(error))
                    return
                }
                if let authResult = authResult {
                    self.onCompletion?(.success(authResult))
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onCompletion?(.failure(error))
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // ViewController 기반으로 Anchor 제공
        return presentingViewController?.view.window ?? UIWindow()
    }

    // MARK: - Helper Functions
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
}
