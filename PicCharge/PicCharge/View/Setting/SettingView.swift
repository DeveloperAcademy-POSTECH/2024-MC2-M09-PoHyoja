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
    @Query var photoForSwiftDatas: [PhotoForSwiftData]

    @State private var myRole: Role
    
    @State private var isShowingLogoutActionSheet = false
    @State private var isShowingWithdrawActionSheet = false
    @State private var isShowingAlert = false
    
    private let version = "1.1.2"
    
    init(myRole: Role) {
        self.myRole = myRole
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                TitleView(title: "설정")
                
                Divider()
                
                List {
                    Section {
                        HStack{
                            VStack(alignment: .leading) {
                                Text("내 계정")
                                Text(userForSwiftDatas.first?.name ?? "없음")
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
                                Text(userForSwiftDatas.first?.connectedTo[0] ?? "없음")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(myRole == .child ? "부모" : "자식")
                                .foregroundStyle(.secondary)
                        }
                    }
                    Section {
//                        Button("서비스 약관 / 개인정보 방침") {
//                            navigationManager.push(to: .settingTermsOfUse)
//                        }
//                        
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
                            navigationManager.userState = .notExist
                            navigationManager.popToRoot()
                        } catch {
                            print("로그아웃 에러: \(error.localizedDescription)")
                        }
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
                        isShowingAlert = true
//                        do {
//                            try deleteUser()
//                            navigationManager.userState = .notExist
//                            navigationManager.popToRoot()
//                        } catch {
//                            print("회원 탈퇴 에러: \(error.localizedDescription)")
//                        }
                    }
                    Button("취소", role: .cancel) {}
                }
            }
            
            Text("version. \(version)")
                .foregroundStyle(.secondary)
                .padding(.top, 200)
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("정말 탈퇴하시겠습니까?"),
                message: Text("탈퇴 후에는 모든 기록이 사라집니다."),
                primaryButton:  .cancel(Text("취소")),
                secondaryButton: .destructive(Text("탈퇴하기")) {
                    //TODO: 현재는 탈퇴하기 눌러도 로그아웃 처리, 추후 탈퇴기능 논의
                    do {
                        try logout()
                        navigationManager.userState = .notExist
                        navigationManager.popToRoot()
                    } catch {
                        print("로그아웃 에러: \(error.localizedDescription)")
                    }
                }
            )
        }
    }
}

extension SettingView {
    private func logout() throws {
        try Auth.auth().signOut()
        print("-- 로컬 데이터 삭제 --")
        deleteLocalData()
    }
    
    private func deleteUser() throws {
        guard Auth.auth().currentUser != nil else {
            throw FirestoreServiceError.userNotFound
        }
        deleteLocalData()
        return
        // TODO: 파이어베이스 서버에서 유저 정보 삭제
        
        // TODO: 로컬에서 유저 정보 삭제
        // try await user.delete()
        
        // TODO: alert 로직으로 성공 실패 표시
    }
    
    private func deleteLocalData() {
        print("-- 로컬 데이터 삭제 --")
        for userForSwiftData in self.userForSwiftDatas {
            modelContext.delete(userForSwiftData)
            print("\(userForSwiftData.name) 유저 삭제")
        }
        for photoForSwiftData in self.photoForSwiftDatas {
            modelContext.delete(photoForSwiftData)
            print("\(photoForSwiftData.id) 사진 삭제")
        }
    }
}

#Preview {
    NavigationStack {
        SettingView(myRole: .child)
            .environment(NavigationManager())
            .preferredColorScheme(.dark)
    }
}
