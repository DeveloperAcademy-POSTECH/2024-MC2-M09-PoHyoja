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
            List {
                Button("사진 1") {
                    navigationManager.path.append(.parentAlbumDetail)
                }
                Button("사진 2") {
                    navigationManager.path.append(.parentAlbumDetail)
                }
                Button("사진 3") {
                    navigationManager.path.append(.parentAlbumDetail)
                }
            }
        }
    }
}

#Preview {
    ParentAlbumView()
        .environment(NavigationManager())
}
