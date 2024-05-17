//
//  ChildCameraView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildCameraView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        Text("카메라 화면")
        Button("사진 촬영") {
            navigationManager.push(to: .childSendCamera)
        }
    }
}

#Preview {
    ChildCameraView()
        .environment(NavigationManager())
}
