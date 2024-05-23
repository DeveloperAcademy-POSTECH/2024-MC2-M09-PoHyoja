//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI
import FirebaseAuth

enum UserState {
    case checkNeeded
    case notConnected
    case connectedChild
    case connectedParent
    case notExist
}

struct ContentView: View {
    @Environment(NavigationManager.self) var navigationManager
    @EnvironmentObject var userManager: UserManager

    @State private var userState: UserState = .checkNeeded
    
    var body: some View {
        Group {
            switch userState {
            case .notExist:
                LoginView(userState: $userState)
            case .notConnected:
                ConnectUserView()
            case .connectedChild:
                ChildTabView()
            case .connectedParent:
                ParentAlbumView()
            default:
                LoginView(userState: $userState)
            }
        }
        .task {
            await checkLoginStatus()
        }
    }
}

private extension ContentView {
    func checkLoginStatus() async {
        if let currentUser = Auth.auth().currentUser,
           let user = await fetchUserAndSetStatus(email: currentUser.email ?? "") {
    
            if user.connectedTo.isEmpty {
                userState = .notConnected
            } else {
                userState = (user.role == .child) ? .connectedChild : .connectedParent
            }
            
        } else {
            userState = .notExist
        }
    }
    
    func fetchUserAndSetStatus(email: String) async -> User? {
        await FirestoreService.shared.fetchUserData(email: email)
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            // TODO: - 로컬 유저 제거
            userState = .notExist
        } catch {
            print("로그아웃 실패")
            throw error
        }
    }
}

#Preview {
    ContentView()
        .environment(NavigationManager())
}
