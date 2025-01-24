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
    
    var body: some View {
        SignInWithAppleButton(
            .continue,
            onRequest: { request in
                userVM.configureAppleSignInRequest(request)
            },
            onCompletion: { result in
                Task {
                    await userVM.processAppleSignInResult(result) // 결과 처리 간소화
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
