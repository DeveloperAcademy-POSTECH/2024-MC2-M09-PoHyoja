//
//  SignUpRoleView.swift
//  PicCharge
//
//  Created by 남유성 on 5/23/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpRoleView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    
    @State var selectedRole: Role = .child
    @State private var isLoading: Bool = false
    
    private let name: String
    private let email: String
    private let password: String
        
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("당신의 역할을 선택해주세요")
                .font(.title2.bold())
                .foregroundStyle(.txtPrimaryDark)
            
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 10) {
                    ZStack {
                        Image("Child")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(Circle())
                        
                        if selectedRole == .child {
                            Circle()
                                .stroke(Color.accent, lineWidth: 4)
                                .frame(width: 100)
                                .transition(.identity)
                        }
                    }
                    .frame(width: 100)
                    
                    Text("자식")
                        .font(.title3)
                        .foregroundStyle(.txtPrimaryDark)
                }
                .onTapGesture {
                    selectedRole = .child
                }
                
                Spacer()
                
                VStack(spacing: 10) {
                    ZStack {
                        Image("Parent")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(Circle())
                        
                        if selectedRole == .parent {
                            Circle()
                                .stroke(Color.accent, lineWidth: 4)
                                .frame(width: 100)
                                .transition(.identity)
                        }
                    }
                    .frame(width: 100)
                    
                    Text("부모")
                        .font(.title3)
                        .foregroundStyle(.txtPrimaryDark)
                }
                .onTapGesture {
                    selectedRole = .parent
                }
                
                Spacer()
            }
            
            Spacer()
            
            FilledBtn(text: "회원가입", isLoading: $isLoading) {
                isLoading = true
                
                Task.detached {
                    do {
                        if password == "" {
                            print("Apple Login 중 회원가입 누름")
                            // 애플 회원가입
                            try await userVM.signUpWithApple(name: name, email: email, role: selectedRole)
                            
                            // 애플 회원가입 완료 후 홈 화면으로 이동
                            await MainActor.run {
                                navigationManager.popToRoot()
                            }
                            
                        } else {
                            // 이메일 회원가입
                            try await userVM.signUp(name: name, email: email, password: password, role: selectedRole)
                            
                            // 이메일 회원가입 완료 후 로그인 화면으로 이동
                            await MainActor.run {
                                navigationManager.pop(to: .emailLogin)
                            }
                        }
                    } catch {
                        await GlobalAlert.shared.show(message: error.localizedDescription)
                    }
                    await MainActor.run { isLoading = false }
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .navigationTitle("역할 선택")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("유저 생성 성공") {
    SignUpRoleView(name: "", email: "", password: "")
        .injectPreviewSetting(user: nil, photos: [], response: .success)
        .preferredColorScheme(.dark)
}

#Preview("유저 생성 에러") {
    SignUpRoleView(name: "", email: "", password: "")
        .injectPreviewSetting(user: nil, photos: [], response: .error)
        .preferredColorScheme(.dark)
}
