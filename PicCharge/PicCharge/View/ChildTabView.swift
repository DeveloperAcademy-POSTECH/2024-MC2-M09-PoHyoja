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
            ChildMainView()
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("Main")
                }
            
            ChildAlbumView()
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Album")
                }
            
            SettingView()
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("My")
                }
            
        }
    }
}

#Preview {
    ChildTabView()
        .environment(NavigationManager())
}
