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
                    if let (isNewUser, email, fullName) = await userVM.processAppleSignInResult(result) {
                        if isNewUser {
                            // 새 사용자 => 회원가입 플로우
                            print("Apple 회원가입, 이름입력하러 가자")
                            navigationManager.push(to: .signUpName(
                                email: email,
                                password: "",
                                name: fullName
                            ))
                        } else {
                            // 기존 사용자 => 홈 화면
                            await userVM.signInWithApple()
                            navigationManager.popToRoot()
                        }
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

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        AppleLoginBtn()
            .injectPreviewDIContainer(user: nil)
    }
    .preferredColorScheme(.dark)
}
