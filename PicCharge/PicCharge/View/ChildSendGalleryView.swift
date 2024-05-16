//
//  ChildSendGalleryView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildSendGalleryView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        Text("사진 전송화면 - 갤러리")
        Button("다시 선택하기") {
            navigationManager.path.removeLast()
        }
        Button("사진 보내기") {
            navigationManager.path.append(.childLoading)
        }
    }
}

#Preview {
    ChildSendGalleryView()
        .environment(NavigationManager())
}
