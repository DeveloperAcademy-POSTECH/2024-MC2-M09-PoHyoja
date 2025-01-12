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
    
    var body: some View {
        TabView(selection: $tab) {
            ChildMainView()
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
    }
}

#Preview {
    NavigationStack {
        ChildTabView()
            .injectDIContainer()
            .preferredColorScheme(.dark)
    }
}
