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
                            Text(userVM.user?.name ?? "없음")
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
                            Text(userVM.user?.connectedTo[0] ?? "없음")
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
                    Task.detached {
                        do {
                            try await userVM.logOut()
                            await MainActor.run { navigationManager.popToRoot() }
                        } catch {
                            await GlobalAlert.shared.show(message: error.localizedDescription)
                        }
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
                primaryButton: .cancel(Text("취소")),
                secondaryButton: .destructive(Text("탈퇴하기")) {
                    Task.detached {
                        do {
                            try await userVM.signOut()
                            await MainActor.run {
                                navigationManager.popToRoot()
                            }
                        } catch {
                            await GlobalAlert.shared.show(message: error.localizedDescription)
                        }
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

#Preview {
    NavigationStack {
        SettingView()
            .injectDIContainer()
            .preferredColorScheme(.dark)
    }
}
