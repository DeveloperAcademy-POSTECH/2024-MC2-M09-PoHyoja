//
//  ChildTabView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildTabView: View {
    @State private var tab: Int = 1
    @Bindable var user: UserForSwiftData
    
    var navigationTitle: String {
        switch tab {
        case 1: "픽-챠"
        case 2: "앨범"
        case 3: "설정"
        default: ""
        }
    }
    
    var body: some View {
        TabView(selection: $tab) {
            Group {
                ChildMainView(user: user)
                    .tabItem {
                        Icon.heartBolt
                        Text("Main")
                    }
                    .tag(1)
                
                ChildAlbumView(user: user)
                    .tabItem {
                        Icon.album
                        Text("Album")
                    }
                    .tag(2)
                
                SettingView(myRole: .child)
                    .tabItem {
                        Icon.setting
                        Text("My")
                    }
                    .background(.bgPrimary)
                    .tag(3)
            }
            .toolbarBackground(.bgPrimary, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(navigationTitle)
        
    }
}

#Preview {
    NavigationStack {
        ChildTabView(user: UserForSwiftData(name: "", role: .child, email: ""))

    }
    .environment(NavigationManager())
    .preferredColorScheme(.dark)
}
