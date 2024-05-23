//
//  LoginView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import Firebase

struct LoginView: View {
    enum Field: Hashable {
        case email
        case password
    }
    
    @Environment(NavigationManager.self) var navigationManager
    
    @Binding var userState: UserState
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isNetworking: Bool = false
    @State private var errorMessage: String? = nil
    
    @FocusState var focusField: Field?
    
    var isLoginAvailable: Bool {
        !email.isEmpty && !password.isEmpty && errorMessage == nil
    }
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack {
                if focusField == nil {
                    Spacer()
                    
                    Text(errorMessage ?? "반갑습니다")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.txtPrimaryDark)
                }
                
                Spacer()
                
                Image("LogoSmall")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 188)
                
                Spacer()
                
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        TextField("이메일", text: $email)
                            .focused($focusField, equals: .email)
                            .autocapitalization(.none)
                            .foregroundStyle(.txtPrimaryDark)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .background(.bgPrimaryElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onChange(of: email) {
                                errorMessage = nil
                            }
                        
                        SecureField("비밀번호", text: $password)
                            .focused($focusField, equals: .password)
                            .foregroundStyle(.txtPrimaryDark)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .background(.bgPrimaryElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onChange(of: password) {
                                errorMessage = nil
                            }
                    }
                    
                    Button {
                        Task {
                            isNetworking = true
                            await signIn(email: email, password: password)
                            isNetworking = false
                        }
                    } label: {
                        ZStack {
                            isLoginAvailable ? Color.green : Color.gray
                            
                            if isNetworking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("로그인")
                                    .bold()
                                    .foregroundStyle(.txtPrimaryDark)
                            }
                        }
                    }
                    .frame(height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .disabled(isNetworking || !isLoginAvailable)
                }
    
                Button {
                    navigationManager.push(to: .signUp)
                } label: {
                    Text("아이디가 없다면? 회원가입 하기!")
                }
                .padding(.vertical, 11)
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            errorMessage = nil
            focusField = nil
        }
        .onTapGesture {
            focusField = nil
        }
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
            errorMessage = "이메일과 비밀번호를 확인해주세요"
        }
    }
}

#Preview {
    LoginView(userState: .constant(.notExist))
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
