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
    // TODO: - 수정 후 지우기
//    @State private var isLogoVisible: Bool = true
    @State private var isNetworking: Bool = false
    @State private var errorMessage: String? = nil
    @FocusState var focusField: Field?
    
    private let authService = AuthService()
    
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
                    .padding(.bottom, 69)
                
                Image("LogoSmall")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 188)
                Spacer()
                
                VStack(spacing: 12) {
                    
                    Button {
                        // 이메일로 로그인 뷰로
                    } label: {
                        ZStack {
                            Color.accentColor
                            
                            if isNetworking {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("이메일로 시작하기")
                                    .font(.system(size: 19))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.txtVibrantPrimary)
                            }
                        }
                    }
                    .frame(height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    Button(action: {
                        signInWithApple()
                    }) {
                        Text(" Apple로 로그인")
                            .frame(maxWidth: .infinity, maxHeight: 54)
                            .background(Color.white)
                            .foregroundStyle(.black)
                            .font(.system(size: 19))
                            .fontWeight(.semibold)
                            .cornerRadius(14)
                    }
                    .padding(.bottom, 5)
                }
                
                // TODO: - 이메일 로그인 뷰에 넣을 버튼 (옮기고 삭제)
//                Button {
//                    navigationManager.push(to: .signUp)
//                } label: {
//                    Text("아이디가 없다면? 회원가입 하기!")
//                        .padding(.vertical, 11)
//                }
//                .padding(.bottom, 16)
                
            }
            .padding(.horizontal, 25)
        }
        .onAppear {
            errorMessage = nil
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
            
            // 로컬 유저 저장
            let localUser = UserEntity(
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
    
    func signInWithApple() {
        Task {
            do {
                // AuthService를 사용해 Apple 로그인 처리
                if let userDTO = try await authService.startSignInWithApple() {
                    // Firestore 데이터 또는 기본값으로 UserEntity 생성
                    let localUser = UserEntity(
                        name: userDTO.name,
                        role: userDTO.role,
                        email: userDTO.email,
                        connectedTo: userDTO.connectedTo,
                        uploadCycle: userDTO.uploadCycle
                    )

                    // 로컬 데이터 저장
                    modelContext.insert(localUser)

                    // Navigation 상태 업데이트
                    if userDTO.connectedTo.isEmpty {
                        navigationManager.userState = .notConnected
                    } else {
                        navigationManager.userState = (userDTO.role == .child) ? .connectedChild : .connectedParent
                    }

                    print("UserEntity 저장 성공: \(localUser)")
                } else {
                    print("Apple 로그인 성공했지만 사용자 정보를 가져올 수 없습니다.")
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
}

#Preview {
    LoginView()
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
