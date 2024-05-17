//
//  ChildAlbumView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildAlbumView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        VStack {
            Text("자식 앨범 화면")
            List {
                Button("사진 1") {
                    navigationManager.push(to: .childAlbumDetail)
                }
                Button("사진 2") {
                    navigationManager.push(to: .childAlbumDetail)
                }
                Button("사진 3") {
                    navigationManager.push(to: .childAlbumDetail)
                }
            }
        }
    }
}

#Preview {
    ChildAlbumView()
        .environment(NavigationManager())
}
