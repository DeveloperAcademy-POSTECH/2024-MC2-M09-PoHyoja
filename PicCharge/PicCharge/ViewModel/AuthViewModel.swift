//
//  AuthViewModel.swift
//  PicCharge
//
//  Created by 이상현 on 5/21/24.
//

import SwiftUI
import Firebase

//class AuthViewModeldeprecated: ObservableObject {
//    @Published var user: User?
//    @Published var isLoggedIn = false
//    @Published var isConnected = false
//    
//    private let firestoreService = FirestoreServicedeprecated.shared
//    private var db = Firestore.firestore()
//    
//    func checkLoginStatus() async {
//        if let currentUser = Auth.auth().currentUser {
//            await fetchUserAndSetStatus(email: currentUser.email ?? "")
//        } else {
//            DispatchQueue.main.async {
//                self.isLoggedIn = false
//            }
//        }
//    }
//    
//    private func fetchUserAndSetStatus(email: String) async {
//        let user = await firestoreService.fetchUserData(email: email)
//        DispatchQueue.main.async {
//            self.user = user
//            self.isLoggedIn = user != nil
//            self.updateConnectionStatus()
//        }
//    }
//    
//    func updateConnectionStatus() {
//        guard let currentUser = user else {
//            self.isConnected = false
//            return
//        }
//        self.isConnected = !currentUser.connectedTo.isEmpty
//    }
//    
//    func signUp(name: String, email: String, password: String, role: Role) async throws {
//        do {
//            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
//            let user = authResult.user
//            
//            let newUser = User(id: user.uid, name: name, role: role, email: email, connectedTo: [])
//            try await firestoreService.saveUserData(user: newUser)
//            
//            DispatchQueue.main.async {
//                self.user = newUser
//                self.isLoggedIn = true
//                self.updateConnectionStatus()
//            }
//        } catch {
//            print("회원 가입 실패")
//            throw error
//        }
//    }
//    
//    func signIn(email: String, password: String) async throws {
//        do {
//            _ = try await Auth.auth().signIn(withEmail: email, password: password)
//            await fetchUserAndSetStatus(email: email)
//        } catch {
//            print("로그인 실패")
//            throw error
//        }
//    }
//    
//    func signOut() throws {
//        do {
//            try Auth.auth().signOut()
//            DispatchQueue.main.async {
//                self.user = nil
//                self.isLoggedIn = false
//                self.isConnected = false
//            }
//        } catch {
//            print("로그아웃 실패")
//            throw error
//        }
//    }
//}
