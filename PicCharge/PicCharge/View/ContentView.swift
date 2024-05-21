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
    @State private var isRoleSelected: Bool = false
    @State private var isConnected: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            determineView()
                .navigationDestination(for: PathType.self) { path in
                    path.NavigatingView()
                }
        }
        .environmentObject(userManager)
        .environmentObject(authViewModel)
        .environment(navigationManager)
        .task {
            await checkAuthenticationStatus()
            await checkUserConnectionStatus()
            handleAutomaticNavigation()
        }
        .onAppear {
            userManager.user = authViewModel.user
            Task {
                await checkAuthenticationStatus()
                await checkUserConnectionStatus()
                handleAutomaticNavigation()
            }
        }
    }

    @ViewBuilder
    private func determineView() -> some View {
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

    private func handleAutomaticNavigation() {
        if isAutoLogined && isRoleSelected && !isConnected {
            navigationManager.push(to: .connectUser)
        }
    }
}

extension ContentView {
    
    // 로그인 상태 확인
    private func checkAuthenticationStatus() async {
        if userManager.isLoggedIn() {
            isAutoLogined = true
        } else {
            isAutoLogined = false
        }
    }

    // 유저 연결여부 확인 함수
    private func checkUserConnectionStatus() async {
        // Firestore에서 연결 상태 확인 로직을 추가하세요.
        // 예를 들어, 사용자의 연결 상태를 확인하는 함수 호출
        // isConnected = await fetchUserConnectionStatus()
        isConnected = false // 예시 코드
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager.shared)
        .environmentObject(AuthViewModel())
}
