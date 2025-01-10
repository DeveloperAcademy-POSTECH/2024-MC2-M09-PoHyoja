//
//  ChildTabView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI
import WidgetKit

struct ChildTabView: View {
    @State private var tab: Int = 1
    @Bindable var user: UserEntity
    @State private var isLoading: Bool = false
    var didRefresh: () async -> Void
    
    var body: some View {
        TabView(selection: $tab) {
            Group {
                ChildMainView(user: user)
                    .tabItem {
                        Icon.heartBolt
                        Text("Main")
                    }
                    .tag(1)
                
                ChildAlbumView()
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
    }
}

#Preview {
    NavigationStack {
        ChildTabView(user: UserEntity(name: "", role: .child, email: ""), didRefresh: { } )
    }
    .environment(NavigationManager())
    .preferredColorScheme(.dark)
}
