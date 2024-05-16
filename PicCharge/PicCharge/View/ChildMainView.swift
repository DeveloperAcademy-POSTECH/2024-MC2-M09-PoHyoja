//
//  ChildMainView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildMainView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        VStack {
            Text("자식 메인 화면")
            Button("사진 올리기") {
                navigationManager.path.append(.childCamera)
            }
            
            Button("사진 찍기") {
                navigationManager.path.append(.childSelectGallery)
            }
        }
    }
}

#Preview {
    ChildMainView()
        .environment(NavigationManager())
}
