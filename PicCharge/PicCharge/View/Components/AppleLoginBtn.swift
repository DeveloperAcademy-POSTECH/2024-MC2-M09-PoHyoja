//
//  AppleLoginBtn.swift
//  PicCharge
//
//  Created by Woowon Kang on 1/23/25.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginBtn: View {
    @Environment(UserViewModel.self) var userVM
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        SignInWithAppleButton(
            .continue,
            onRequest: { request in
                userVM.configureAppleSignInRequest(request)
            },
            onCompletion: { result in
                Task {
                    if let email = await userVM.processAppleSignInResult(result) {
                        // SignUpNameView로 이메일과 더미 비밀번호 전달
                        navigationManager.push(to: .signUpName(
                            email: email,
                            password: ""
                        ))
                    } else {
                        print("Apple 로그인 실패 또는 취소됨")
                    }
                }
            }
        )
        .signInWithAppleButtonStyle(.white)
        .frame(height: 54)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    AppleLoginBtn()
}
