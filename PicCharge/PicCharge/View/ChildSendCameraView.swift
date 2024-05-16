//
//  ChildSendCameraView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildSendCameraView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        VStack {
            Text("사진 전송화면 - 카메라")
            Button("다시 찍기") {
                navigationManager.path.removeLast()
            }
            Button("사진 보내기") {
                navigationManager.path.append(.childLoading)
            }
        }
    }
}

#Preview {
    ChildSendCameraView()
        .environment(NavigationManager())
}
