//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var navigationManager = NavigationManager()
    @EnvironmentObject var userManager: UserManager
    @State private var isLoading: Bool = true

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            Group {
                if isLoading {
                    LoadingView()
                }
            }
            .navigationDestination(for: PathType.self) { path in
                path.NavigatingView()
                    .environmentObject(userManager)
            }
        }
        .task {
            await checkLoginStatus()
            isLoading = false
            updateNavigation()
        }
    }
}

private extension ContentView {
    func checkLoginStatus() async {
        if let currentUser = Auth.auth().currentUser {
            await fetchUserAndSetStatus(email: currentUser.email ?? "")
        } else {
            DispatchQueue.main.async {
                self.userManager.user = nil
            }
        }
    }
    
    func fetchUserAndSetStatus(email: String) async {
        let user = await FirestoreService.shared.fetchUserData(email: email)
        DispatchQueue.main.async {
            self.userManager.user = user
            self.updateConnectionStatus()
            self.updateNavigation()
        }
    }
    
    func updateConnectionStatus() {
        guard let currentUser = userManager.user else {
            self.userManager.isConnected = false
            return
        }
        self.userManager.isConnected = !currentUser.connectedTo.isEmpty
    }
    
    func updateNavigation() {
        if userManager.user == nil {
            navigationManager.push(to: .login)
        } else if !userManager.isConnected {
            navigationManager.push(to: .connectUser)
        } else if let currentUser = userManager.user {
            if currentUser.role == .child {
                navigationManager.push(to: .childTab)
            } else {
                navigationManager.push(to: .parentAlbum)
            }
        }
    }
    
    func signUp(name: String, email: String, password: String, role: Role) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = authResult.user
            
            let newUser = User(id: user.uid, name: name, role: role, email: email, connectedTo: [])
            try await FirestoreService.shared.saveUserData(user: newUser)
            
            DispatchQueue.main.async {
                self.userManager.user = newUser
                self.updateConnectionStatus()
                self.updateNavigation()
            }
        } catch {
            print("회원 가입 실패")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            await fetchUserAndSetStatus(email: email)
        } catch {
            print("로그인 실패")
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.userManager.user = nil
                self.userManager.isConnected = false
                self.updateNavigation()
            }
        } catch {
            print("로그아웃 실패")
            throw error
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
        .environment(NavigationManager())
}
