//
//  ChildGalleryView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildSelectGalleryView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        Text("갤러리 선택 화면")
        Button("사진 선택") {
            navigationManager.push(to: .childSendGallery)
        }
    }
}

#Preview {
    ChildSelectGalleryView()
        .environment(NavigationManager())
}
