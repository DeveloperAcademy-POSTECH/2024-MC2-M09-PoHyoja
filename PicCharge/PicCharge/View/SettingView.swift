//
//  SettingView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        List {
            Text("설정 화면")
            Button("이용약관") {
                navigationManager.push(to: .settingTermsOfUse)
            }
            Button("로그아웃") {
                navigationManager.popToRoot()
            }
            Button("회원탈퇴") {
                navigationManager.popToRoot()
            }
        }
        
    }
}

#Preview {
    SettingView()
}
