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

    @State private var role: Role = .child
    @State private var isAutoLogined: Bool = false
    @State private var isRoleSelected: Bool = false
    @State private var isConnected: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack {
                Text("여기는 실제로 보이지 않는 화면입니다.")
                if userManager.isLoggedIn() {
                    Text("현재 \(userManager.user?.id ?? "ERROR")로 로그인 되었습니다.")
                } else {
                    Text("로그인 안됨")
                }
                
                Toggle("자동 로그인 성공", isOn: $isAutoLogined)
                Toggle("역할 선택 완료", isOn: $isRoleSelected)
                Toggle("부모 자식 연결 완료", isOn: $isConnected)
                
                VStack(alignment: .leading) {
                    Button("[로그인X] 로그인 화면으로") {
                        navigationManager.push(to: .login)
                    }
                    .disabled(isAutoLogined)
                    
                    //                    Button("[로그인O] 역할선택화면으로") {
                    //                        navigationManager.push(to: .selectRole)
                    //                    }
                    //                    .disabled(!(isAutoLogined && !isRoleSelected && !isConnected))
                    
                    Button("[로그인O,역할O] 유저연결화면으로") {
                        navigationManager.push(to: .connectUser)
                    }
                    .disabled(!(isAutoLogined && isRoleSelected && !isConnected))
                    
                    Button("[로그인O,역할O,연결O] \(role)메인화면으로") {
                        navigationManager.push(to: role == .child ? .childTab : .parentAlbum)
                    }
                    .disabled(!(isAutoLogined && isRoleSelected && isConnected))
                }
            }
            .navigationDestination(for: PathType.self) { path in
                path.NavigatingView()
            }
        }
        .environmentObject(userManager)
        .environment(navigationManager)
        .task {
            await checkAuthenticationStatus()
            await checkRoleSelectionStatus()
            await checkUserConnectionStatus()
        }
    }
}

extension ContentView {
    
    // 로그인 상태 확인
    private func checkAuthenticationStatus() async {
        if userManager.isLoggedIn() {
            isAutoLogined = true
            role = userManager.user?.role ?? .child
            // 역할 선택과 연결 상태도 자동으로 설정할 수 있다면 여기서 추가로 처리
        } else {
            isAutoLogined = false
        }
    }
       
    // 역할 선택여부 함수
    private func checkRoleSelectionStatus() async {
        // TODO: - 역할 선택여부 함수 구현
        isRoleSelected = false
    }
     
    // 유저 연결여부 확인 함수
    private func checkUserConnectionStatus() async {
        // TODO: - 유저 연결여부 확인 함수 구현
        isConnected = false
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager.shared)
}
