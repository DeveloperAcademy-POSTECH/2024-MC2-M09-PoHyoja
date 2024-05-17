//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationManager = NavigationManager()
    
    @State private var role: Role = .child
    @State private var isAutoLogined: Bool = false
    @State private var isRoleSelected: Bool = false
    @State private var isConnected: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack {
                Text("여기는 실제로 보이지 않는 화면입니다.")
                
                Picker("부모자식 역할", selection: $role) {
                    ForEach(Role.allCases, id: \.self) { role in
                        Text("\(role)")
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("자동 로그인 성공", isOn: $isAutoLogined)
                Toggle("역할 선택 완료", isOn: $isRoleSelected)
                Toggle("부모 자식 연결 완료", isOn: $isConnected)
                
                VStack(alignment: .leading) {
                    Button("[로그인X] 로그인 화면으로") {
                        navigationManager.push(to: .login)
                    }
                    .disabled(isAutoLogined)
                    
                    Button("[로그인O] 역할선택화면으로") {
                        navigationManager.push(to: .selectRole)
                    }
                    .disabled(!(isAutoLogined && !isRoleSelected && !isConnected))
                    
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
        .environment(navigationManager)
        .task {
            await checkAuthenticationStatus()
            await checkRoleSelectionStatus()
            await checkUserConnectionStatus()
        }
    }
}

extension ContentView {
    private func checkAuthenticationStatus() async {
        // TODO: - 자동 로그인 함수 구현
        isAutoLogined = false
    }
       
    private func checkRoleSelectionStatus() async {
        // TODO: - 역할 선택여부 함수 구현
        isRoleSelected = false
    }
       
    private func checkUserConnectionStatus() async {
        // TODO: - 유저 연결여부 확인 함수 구현
        isConnected = false
    }
}

#Preview {
    ContentView()
}
