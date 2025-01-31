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
            
            SettingView()
                .tabItem {
                    Icon.setting
                    Text("My")
                }
                .background(.bgPrimary)
                .tag(3)
        }
        .transition(.opacity.animation(.easeInOut(duration: 1)))
    }
}

#Preview("사진 동기화 성공") {
    ChildTabView()
        .injectPreviewDIContainer(
            user: .childMock,
            localPhotos: [.withDataMock1],
            remotePhotos: [.withDataMock1, .withDataMock2, .withDataMock3],
            response: .success
        )
        .preferredColorScheme(.dark)
}

#Preview("사진 동기화 실패") {
    ChildTabView()
        .injectPreviewDIContainer(
            user: .childMock,
            localPhotos: [.withDataMock1],
            remotePhotos: [.withDataMock1, .withDataMock2, .withDataMock3],
            response: .error
        )
        .preferredColorScheme(.dark)
}

#Preview("사진 데이터 없음") {
    ChildTabView()
        .injectPreviewDIContainer(
            user: .childMock,
            photos: []
        )
        .preferredColorScheme(.dark)
}

#Preview("일주일 전 업로드") {
    ChildTabView()
        .injectPreviewDIContainer(
            user: .childMock,
            photos: [.oneWeekAgo]
        )
        .preferredColorScheme(.dark)
}

#Preview("2일 전 업로드") {
    ChildTabView()
        .injectPreviewDIContainer(
            user: .childMock,
            photos: [.twoDayAgo]
        )
        .preferredColorScheme(.dark)
}

#Preview("1일 전 업로드") {
    ChildTabView()
        .injectPreviewDIContainer(
            user: .childMock,
            photos: [.oneDayAgo]
        )
        .preferredColorScheme(.dark)
}
