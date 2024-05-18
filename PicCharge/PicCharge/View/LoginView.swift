//
//  LoginView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        NavigationView {
            Text("로그인/회원가입 화면")
            Button("애플 로그인") {
                navigationManager.push(to: .selectRole)
            }
        }
    }
}


#Preview {
    LoginView()
        .environment(NavigationManager())
}


