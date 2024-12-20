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
    @Environment(\.modelContext) var modelContext

    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isLogoVisible: Bool = true
    @State private var isNetworking: Bool = false
    @State private var errorMessage: String? = nil
    
    @FocusState var focusField: Field?
    
    var isLoginAvailable: Bool {
        !email.isEmpty && !password.isEmpty && errorMessage == nil
    }
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        focusField = nil
                    }
                }
            
            VStack {
                Spacer()
                
                Text(errorMessage ?? "반갑습니다")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.txtPrimaryDark)
                
                if isLogoVisible {
                    Spacer()
                    
                    Image("LogoSmall")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 188)
                        .animation(.easeInOut(duration: 0.1), value: isLogoVisible)
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                }
                
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
                        .padding(.vertical, 11)
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            errorMessage = nil
            focusField = nil
        }
        .onChange(of: focusField) {
            withAnimation {
                isLogoVisible = (focusField == nil)
            }
        }
    }
}

private extension LoginView {
    func signIn(email: String, password: String) async {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            guard let user = await FirestoreService.shared.fetchUserByEmail(email: email) else { throw FirestoreServiceError.userNotFound
            }
            
            // 로컬 유저 저장
            let localUser = UserForSwiftData(
                name: user.name,
                role: user.role,
                email: user.email,
                connectedTo: user.connectedTo,
                uploadCycle: user.uploadCycle
            )
            modelContext.insert(localUser)
            if user.connectedTo.isEmpty {
                navigationManager.userState = .notConnected
            } else {
                navigationManager.userState = (user.role == .child) ? .connectedChild : .connectedParent
            }
        } catch {
            do {
                try Auth.auth().signOut()
            } catch {
                print("Auth 로그아웃 실패: \(error)")
            }
            print("로그인 실패")
            errorMessage = "이메일과 비밀번호를 확인해주세요"
        }
    }
}

#Preview {
    LoginView()
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
