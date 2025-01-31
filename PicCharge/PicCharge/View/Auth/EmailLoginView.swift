//
//  EmailLoginView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import Firebase

extension EmailLoginView {
    enum Field: Hashable {
        case email, password
    }
}

struct EmailLoginView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isNetworking: Bool = false
    
    @FocusState var focusField: Field?
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("이메일로 로그인")
                    .font(.system(size: 22))
                    .fontWeight(.black)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이메일")
                        .font(.system(size: 17))
                        .foregroundStyle(.accent)
                    
                    TextField("이메일", text: $email)
                        .focused($focusField, equals: .email)
                        .autocapitalization(.none)
                        .foregroundStyle(.txtPrimaryDark)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .background(.bgPrimaryElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("비밀번호")
                        .font(.system(size: 17))
                        .foregroundStyle(.accent)
                    
                    SecureField("비밀번호", text: $password)
                        .focused($focusField, equals: .password)
                        .foregroundStyle(.txtPrimaryDark)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .background(.bgPrimaryElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    navigationManager.push(to: .signUpEmailPw)
                } label: {
                    HStack {
                        Text("아이디가 없다면?")
                        Text("회원가입 하기!")
                            .underline()
                    }
                    .padding(.vertical, 11)
                }
                
                Spacer()
                
                FilledBtn(text: "로그인", isLoading: $isNetworking) {
                    isNetworking = true
                    Task.detached {
                        await userVM.signIn(with: email, password: password)
                        await MainActor.run { isNetworking = false }
                    }
                }
                .disabled(isNetworking)
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.bottom, 16)
        }
        .onAppear {
            focusField = nil
        }
        .onChange(of: userVM.state) { oldValue, newValue in
            switch newValue {
            case .connected, .notConnected:
                navigationManager.popToRoot()
            default:
                break
            }
        }
    }
}

#Preview {
    EmailLoginView()
        .injectPreviewSetting(user: nil)
        .preferredColorScheme(.dark)
}
