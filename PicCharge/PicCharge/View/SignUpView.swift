//
//  SignupView.swift
//  PicCharge
//
//  Created by 이상현 on 5/21/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(NavigationManager.self) var navigationManager
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
                .padding(.horizontal)
            
            TextField("이메일", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("비밀번호", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("비밀번호 확인", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Picker("역할 선택", selection: $selectedRole) {
                ForEach(Role.allCases, id: \.self) { role in
                    Text(role.rawValue.capitalized).tag(role)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button(action: {
                Task {
                    await signUp()
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

private extension SignUpView {
    func signUp() async {
        do {
            guard password == confirmPassword else {
                self.errorMessage = "비밀번호가 일치하지 않습니다."
                return
            }
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = authResult.user
            
            let newUser = User(id: user.uid, name: name, role: selectedRole, email: email, connectedTo: [])
            try await FirestoreService.shared.saveUserData(user: newUser)
            
            DispatchQueue.main.async {
                self.userManager.user = newUser
                self.errorMessage = nil
                navigationManager.pop()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(UserManager())
}
