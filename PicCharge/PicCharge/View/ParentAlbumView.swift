//
//  ParentAlbumView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ParentAlbumView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        VStack {
            Text("부모 앨범 화면")
            Button("설정") {
                navigationManager.push(to: .setting)
            }
            List {
                Button("사진 1") {
                    navigationManager.push(to: .parentAlbumDetail)
                }
                Button("사진 2") {
                    navigationManager.push(to: .parentAlbumDetail)
                }
                Button("사진 3") {
                    navigationManager.push(to: .parentAlbumDetail)
                }
            }
        }
    }
}

#Preview {
    ParentAlbumView()
        .environment(NavigationManager())
}
