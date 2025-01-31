//
//  SignUpEmailPasswordView.swift
//  PicCharge
//
//  Created by 남유성 on 1/15/25.
//

import SwiftUI

struct SignUpEmailPasswordView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @FocusState private var focus: Int?
    
    private var isValidEmail: Bool { email.isValidEmail }
    private var isValidPassword: Bool { password == confirmPassword && password.count >= 6 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("이메일")
                    .font(.title2.bold())
                    .fontWeight(.black)
                
                TextField("이메일", text: $email)
                    .autocapitalization(.none)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .focused($focus, equals: 0)
                
                Text(isValidEmail ? "사용 가능한 이메일입니다." : "잘못된 이메일 형식입니다.")
                    .font(.system(size: 17))
                    .foregroundStyle(isValidEmail ? .accent : .red)
                    .opacity(email.isEmpty ? 0 : 1)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("비밀번호")
                    .font(.system(size: 22))
                    .fontWeight(.black)
                
                SecureField("비밀번호", text: $password)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .focused($focus, equals: 1)
                
                Text(password.count >= 6 ? "사용 가능한 비밀번호 입니다." : "6자리 이상의 비밀번호를 입력해주세요.")
                    .font(.system(size: 17))
                    .foregroundStyle(password.count >= 6 ? .accent : .red)
                    .opacity(password.isEmpty ? 0 : 1)
                
                Text("비밀번호 확인")
                    .font(.system(size: 22))
                    .fontWeight(.black)
                
                SecureField("비밀번호 확인", text: $confirmPassword)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .focused($focus, equals: 2)
                
                Text(password == confirmPassword ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다.")
                    .font(.system(size: 17))
                    .foregroundStyle(password == confirmPassword ? .accent : .red)
                    .opacity(password.isEmpty || confirmPassword.isEmpty ? 0 : 1)
            }
            
            Spacer()
            
            FilledBtn(
                text: "다음 단계",
                isActive: .init(get: { isValidEmail && isValidPassword }, set: { _ in }),
                isLoading: $isLoading
            ) {
                isLoading = true
                
                Task.detached {
                    let isAvailable = await userVM.checkEmailAvailable(email: email)
                    
                    await MainActor.run {
                        isLoading = false
                        
                        if isAvailable {
                            navigationManager.push(to: .signUpName(email: email, password: password))
                        } else {
                            email = ""
                            password = ""
                            confirmPassword = ""
                            focus = 0
                        }
                    }
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .navigationTitle("이메일 입력")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SignUpEmailPasswordView()
        .injectPreviewDIContainer(user: nil)
        .preferredColorScheme(.dark)
}
