//
//  SignupView.swift
//  PicCharge
//
//  Created by 이상현 on 5/21/24.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userManager: UserManager
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var selectedRole: Role = .child
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            TextField("이름", text: $name)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("이메일", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("비밀번호", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("비밀번호 확인", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("역할 선택", selection: $selectedRole) {
                ForEach(Role.allCases, id: \.self) { role in
                    Text(role.rawValue.capitalized).tag(role)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button(action: {
                guard password == confirmPassword else {
                    self.errorMessage = "비밀번호가 일치하지 않습니다."
                    return
                }

                authViewModel.signUp(name: name, email: email, password: password, role: selectedRole) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.errorMessage = nil
                        userManager.user = authViewModel.user
                    }
                }
            }) {
                Text("회원 가입")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserManager())
}
