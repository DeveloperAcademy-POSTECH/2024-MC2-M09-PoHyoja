//
//  UserInfoForSignUpView.swift
//  PicCharge
//
//  Created by 이상현 on 5/21/24.
//

import SwiftUI
import FirebaseAuth

struct UserInfoForSignUpView: View {
    @Environment(NavigationManager.self) var navigationManager

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
        
    var isSignUpAvailable: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && errorMessage == nil
    }
    
    init(errorMessage: String?) {
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(errorMessage ?? "기본 정보를 입력해주세요")
                .font(.title2.bold())
                .foregroundStyle(.txtPrimaryDark)
                .padding(.top, 40)
            
            VStack(spacing: 8) {
                TextField("이름", text: $name)
                    .autocapitalization(.none)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onChange(of: name) {
                        errorMessage = nil
                    }
                
                TextField("이메일", text: $email)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onChange(of: email) {
                        errorMessage = nil
                    }
                
                SecureField("비밀번호", text: $password)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onChange(of: password) {
                        errorMessage = nil
                    }
                
                SecureField("비밀번호 확인", text: $confirmPassword)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onChange(of: confirmPassword) {
                        errorMessage = nil
                    }
            }
            
            Spacer()
            
            Button {
                navigationManager.push(to: .selectRole(name: name, email: email, password: password))
            } label: {
                ZStack {
                    isSignUpAvailable ? Color.green : Color.gray
                    
                    Text("다음 단계")
                        .bold()
                        .foregroundStyle(.txtPrimaryDark)
                }
            }
            .frame(height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .disabled(!isSignUpAvailable)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .navigationTitle("기본 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    UserInfoForSignUpView(errorMessage: nil)
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
