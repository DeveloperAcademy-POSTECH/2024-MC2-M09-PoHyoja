//
//  SelectRoleView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct SelectRoleView: View {
    @Environment(NavigationManager.self) var navigationManager
    
    var body: some View {
        Text("자식/부모 역할 선택화면")
        Button("다음 단계로") {
            navigationManager.path.append(.connectUser)
        }
    }
}

#Preview {
    SelectRoleView()
        .environment(NavigationManager())
}
