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
    
    
    @Binding var userState: UserState
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
                    await signIn(email: email, password: password)
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
    func signIn(email: String, password: String) async {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            guard let user = await FirestoreService.shared.fetchUserByEmail(email: email) else { throw FirestoreServiceError.userNotFound
            }
            
            // TODO: - 로컬 유저 저장
            if user.connectedTo.isEmpty {
                userState = .notConnected
            } else {
                userState = (user.role == .child) ? .connectedChild : .connectedParent
            }
            
        } catch {
            print("로그인 실패")
        }
    }
}

#Preview {
    LoginView(userState: .constant(.notExist))
        .environment(NavigationManager())
}
