//
//  ChildTabView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildTabView: View {
    var body: some View {
        TabView {
            Group {
                ChildMainView()
                    .tabItem {
                        Image(systemName: Icon.heartBolt)
                        Text("Main")
                    }
                
                ChildAlbumView()
                    .tabItem {
                        Image(systemName: Icon.album)
                        Text("Album")
                    }
                
                SettingView()
                    .tabItem {
                        Image(systemName: Icon.setting)
                        Text("My")
                    }.background(.bgPrimary)
            }
            .toolbarBackground(.bgPrimary, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

#Preview {
    ChildTabView()
        .environment(NavigationManager())
}
