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
    @State private var isAutoLogined: Bool = false
    @State private var isRoleSelected: Bool = false
    @State private var isConnected: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            EmptyView()
                .navigationDestination(for: PathType.self) { path in
                    path.NavigatingView()
                }
        }
        .environment(navigationManager)
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
        isAutoLogined = false
    }

    // 유저 연결여부 확인 함수
    private func checkUserConnectionStatus() async {
        // TODO: 연결 상태 확인 로직을 추가
        isConnected = false
    }
}

#Preview {
    ContentView()
}
