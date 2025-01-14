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
    @Environment(PhotoViewModel.self) var photoVM
    @Environment(UserViewModel.self) var userVM
    @Environment(\.modelContext) var modelContext
    @Query var userForSwiftDatas: [UserEntity]
    
    @State private var isShowingLogoutActionSheet = false
    @State private var isShowingWithdrawActionSheet = false
    @State private var isShowingWithdrawAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            Header("설정")
            
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
                        Text(userVM.user?.role == .child ? "자식" : "부모")
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
                        Text(userVM.user?.role == .child ? "부모" : "자식")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    HStack {
                        Text("버전 정보")
                        Spacer()
                        Text("v\(Utils.getAppVersion())").foregroundStyle(.secondary)
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
            
            HStack {
                Button {
                    openWebsite(urlString: AppURL.termsOfService)
                } label: {
                    Text("이용 약관").underline()
                }
                Text("|")
                
                Button {
                    openWebsite(urlString: AppURL.privacyPolicy)
                } label: {
                    Text("개인 정보 처리 방침").underline()
                }
            }
            .font(.callout)
            .foregroundStyle(.txtVibrantTertiary)
            .padding(.bottom, 40)
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
                        GlobalAlert.shared.show(message: error.localizedDescription)
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
                    isShowingWithdrawAlert = true
                }
                Button("취소", role: .cancel) {}
            }
        }
        .alert(isPresented: $isShowingWithdrawAlert) {
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
                        GlobalAlert.shared.show(message: error.localizedDescription)
                    }
                }
            )
        }
    }
}

extension SettingView {
    private func openWebsite(urlString: String) {
        guard let url = URL(string: urlString) else {
            GlobalAlert.shared.show(message: "해당 링크를 열 수 없습니다.")
            return
        }
        
        UIApplication.shared.open(url)
    }
}

extension SettingView {
    private func logout() throws {
        try Auth.auth().signOut()
        
        print("-- 로컬 데이터 삭제 --")
        try deleteLocalData()
    }
    
    private func deleteUser() throws {
        guard Auth.auth().currentUser != nil else {
            throw FirestoreServiceError.userNotFound
        }
        
        try deleteLocalData()
        
        // TODO: 파이어베이스 서버에서 유저 정보 삭제
        
        // TODO: 로컬에서 유저 정보 삭제
        // try await user.delete()
        
        // TODO: alert 로직으로 성공 실패 표시
    }
    
    private func deleteLocalData() throws {
        print("-- 로컬 데이터 삭제 --")
        for userForSwiftData in self.userForSwiftDatas {
            modelContext.delete(userForSwiftData)
            print("\(userForSwiftData.name) 유저 삭제")
        }
        
        Task.detached {
            do {
                try await photoVM.deleteAllLocal()
            } catch {
                // 로컬 사진 삭제 실패는 무시
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
            .injectDIContainer()
            .preferredColorScheme(.dark)
    }
}
