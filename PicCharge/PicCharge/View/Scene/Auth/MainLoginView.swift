//
//  MainLoginView.swift
//  PicCharge
//
//  Created by 남유성 on 1/15/25.
//

import SwiftUI

struct MainLoginView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 70) {
                Spacer()
                
                Text("반갑습니다")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.txtPrimaryDark)
                
                Image("LogoSmall")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 188)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                FilledBtn(text: "이메일로 시작하기") {
                    navigationManager.push(to: .emailLogin)
                }
                AppleLoginBtn()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    MainLoginView()
        .environment(NavigationManager())
        .preferredColorScheme(.dark)
}
