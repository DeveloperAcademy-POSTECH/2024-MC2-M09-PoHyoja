//
//  ChildLoadingView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildLoadingView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        Text("로딩 화면")
        Button("전송 후 로딩 끝!") {
            // TODO: - 하드 코딩 삭제
            navigationManager.path.removeLast(3)
        }
    }
}

#Preview {
    ChildLoadingView()
        .environment(NavigationManager())
}
