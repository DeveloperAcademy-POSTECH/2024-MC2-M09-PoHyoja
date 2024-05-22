//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationManager = NavigationManager()
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isAutoLogined: Bool = false
    @State private var isConnected: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            DetermineView()
                .navigationDestination(for: PathType.self) { path in
                    path.NavigatingView()
                }
        }
        .environment(navigationManager)
        .task {
            await checkAuthenticationStatus()
            await checkUserConnectionStatus()
        }
        .onReceive(authViewModel.$isLoggedIn) { isLoggedIn in
            self.isAutoLogined = isLoggedIn
        }
        .onReceive(authViewModel.$user) { user in
            self.userManager.user = user
        }
    }

    @ViewBuilder
    private func DetermineView() -> some View {
        if !isAutoLogined {
            LoginView()
        } else if !isConnected {
            ConnectUserView()
        } else {
            if let currentUser = userManager.user {
                if currentUser.role == .child {
                    ChildTabView()
                } else {
                    ParentAlbumView()
                }
            }
            
        }
    }
}

extension ContentView {
    
    // 로그인 상태 확인
    private func checkAuthenticationStatus() async {
        self.isAutoLogined = authViewModel.isLoggedIn
    }

    // 유저 연결여부 확인 함수
    private func checkUserConnectionStatus() async {
        // TODO: 연결 상태 확인 로직을 추가
        isConnected = false
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
        .environmentObject(AuthViewModel())
}
