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
    @Environment(\.modelContext) var modelContext
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
            
            // 로컬 유저 저장
            var localUser = UserForSwiftData(
                name: user.name,
                role: user.role,
                email: user.email,
                connectedTo: user.connectedTo,
                uploadCycle: user.uploadCycle
            )
            modelContext.insert(localUser)
            if user.connectedTo.isEmpty {
                userState = .notConnected
            } else {
                userState = (user.role == .child) ? .connectedChild : .connectedParent
            }
            
        } catch {
            do {
                try Auth.auth().signOut()
            } catch {
                print("Auth 로그아웃 실패: \(error)")
            }
            print("로그인 실패")
        }
    }
}
