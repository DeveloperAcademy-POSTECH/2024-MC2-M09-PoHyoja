//
//  SettingView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    // TODO: - 유저 모델 주입
    @State private var myId: String = "imyourson"
    @State private var connectedId: String = "iamdaddy"
    @State private var myRole: Role = .child
    
    @State private var isShowingLogoutActionSheet = false
    @State private var isShowingWithdrawActionSheet = false
    
    private let version = "1.0.0"
    
    var body: some View {
        ZStack {
            List {
                Section {
                    HStack{
                        VStack(alignment: .leading) {
                            Text("내 계정")
                            Text(myId)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(myRole == .child ? "자식" : "부모")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("연결된 계정")
                            Text(connectedId)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(myRole == .child ? "부모" : "자식")
                            .foregroundStyle(.secondary)
                    }
                }
                Section {
                    Button("서비스 약관 / 개인정보 방침") {
                        navigationManager.push(to: .settingTermsOfUse)
                    }
                    
                    Button("로그아웃") {
                        isShowingLogoutActionSheet = true
                    }
                    
                    Button("회원탈퇴") {
                        isShowingWithdrawActionSheet = true
                    }
                    .foregroundStyle(.grpRed)
                }
                .foregroundStyle(.txtPrimaryDark)
            }
            .scrollDisabled(true)
            .confirmationDialog(
                "로그아웃 하시겠습니까?",
                isPresented: $isShowingLogoutActionSheet,
                titleVisibility: .visible
            ) {
                VStack {
                    Button("로그아웃", role: .destructive) {
                        // TODO: - 로그아웃 처리
                        navigationManager.popToRoot()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                
            }
            .confirmationDialog(
                "회원을 탈퇴하시겠습니까? \n 탈퇴하면 되돌릴 수 없고, 저희가 슬퍼요.",
                isPresented: $isShowingWithdrawActionSheet,
                titleVisibility: .visible
            ) {
                VStack {
                    Button("로그아웃", role: .destructive) {
                        // TODO: - 로그아웃 처리
                        navigationManager.popToRoot()
                    }
                    Button("탈퇴하기", role: .destructive) {
                        // TODO: - 탈퇴 처리
                        navigationManager.popToRoot()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            
            Text("version. \(version)")
                .foregroundStyle(.secondary)
                .padding(.top, 200)
        }
    }
}

#Preview {
    SettingView()
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
