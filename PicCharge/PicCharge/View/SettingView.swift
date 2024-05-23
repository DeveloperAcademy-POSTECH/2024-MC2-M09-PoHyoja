//
//  SettingView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct SettingView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(\.modelContext) var modelContext
    @Query var userForSwiftDatas: [UserForSwiftData]

    // TODO: - 유저 모델 주입
    @State private var myRole: Role
    
    @State private var isShowingLogoutActionSheet = false
    @State private var isShowingWithdrawActionSheet = false
    
    private let version = "1.0.0"
    
    init(myRole: Role) {
        self.myRole = myRole
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Divider()
                
                List {
                    Section {
                        HStack{
                            VStack(alignment: .leading) {
                                Text("내 계정")
                                Text(userForSwiftDatas.first!.name)
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
                                Text(userForSwiftDatas.first!.connectedTo[0])
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
            }
            .confirmationDialog(
                "로그아웃 하시겠습니까?",
                isPresented: $isShowingLogoutActionSheet,
                titleVisibility: .visible
            ) {
                VStack {
                    Button("로그아웃", role: .destructive) {
                        do {
                            try logout()
                        } catch {
                            print("로그아웃 에러: \(error.localizedDescription)")
                        }
                        navigationManager.popToRoot()
                    }
                    Button("취소", role: .cancel) {}
                }
            }
            .confirmationDialog(
                "회원을 탈퇴하시겠습니까? \n 탈퇴하면 되돌릴 수 없고, 저희가 슬퍼요.",
                isPresented: $isShowingWithdrawActionSheet,
                titleVisibility: .visible
            ) {
                VStack {
                    Button("탈퇴하기", role: .destructive) {
                        do {
                            try deleteUser()
                        } catch {
                            print("회원 탈퇴 에러: \(error.localizedDescription)")
                        }
                        navigationManager.popToRoot()
                    }
                    Button("취소", role: .cancel) {}
                }
            }
            
            Text("version. \(version)")
                .foregroundStyle(.secondary)
                .padding(.top, 200)
        }
    }
}

extension SettingView {
    private func logout() throws {
        try Auth.auth().signOut()
        for userForSwiftData in self.userForSwiftDatas {
            modelContext.delete(userForSwiftData)
        }
    }
    
    private func deleteUser() throws {
        guard let user = Auth.auth().currentUser else {
            throw FirestoreServiceError.userNotFound
        }
        for userForSwiftData in self.userForSwiftDatas {
            modelContext.delete(userForSwiftData)
        }
        return
        // TODO: 파이어베이스 서버에서 유저 정보 삭제
        
        // TODO: try await user.delete()
        
        // TODO: alert 로직으로 성공 실패 표시
    }
}

#Preview {
    NavigationStack {
        SettingView(myRole: .child)
            .environment(NavigationManager())
            .preferredColorScheme(.dark)
    }
}
