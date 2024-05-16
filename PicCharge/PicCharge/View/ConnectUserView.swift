//
//  ConnectUserView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ConnectUserView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        Text("유저 연결 화면")
        Button("연결 승인") {
            navigationManager.path.removeAll()
        }
    }
}

#Preview {
    ConnectUserView()
        .environment(NavigationManager())
}
