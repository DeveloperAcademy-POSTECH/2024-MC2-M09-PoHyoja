//
//  LoginView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @Environment(NavigationManager.self) var navigationManager
    @EnvironmentObject var userManager: UserManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            TextField("이메일", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("비밀번호", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                Task {
                    await signIn()
                }
            }) {
                Text("로그인")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Button(
                action: {
                    navigationManager.push(to: .signUp)
                }) {
                    Text("아이디가 없다면? 회원가입 하기!")
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

private extension LoginView {
    func signIn() async {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = authResult.user
            
            let fetchedUser = await FirestoreService.shared.fetchUserData(email: email)
            DispatchQueue.main.async {
                if let fetchedUser = fetchedUser {
                    self.userManager.user = fetchedUser
                    self.errorMessage = nil
                    navigationManager.pop() // 로그인 성공 후 이전 화면으로 이동
                } else {
                    self.errorMessage = "사용자 정보를 가져오는 데 실패했습니다."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
#Preview {
    LoginView()
        .environmentObject(UserManager())
}
