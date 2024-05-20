//
//  SelectRoleView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct SelectRoleView: View {
    @Environment(NavigationManager.self) var navigationManager
    var userId: String
    
    var body: some View {
        VStack {
            Text("자식/부모 역할 선택화면")
            Button("부모 역할로 가입") {
                Task {
                    await selectRole(role: .parent)
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Button("자식 역할로 가입") {
                Task {
                    await selectRole(role: .child)
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
    }
}

extension SelectRoleView {
    private func selectRole(role: Role) async {
        do {
            // TODO: email 테스트
            let newUser = User(id: userId, email: "test@test.com", role: role, connectedTo: [], uploadCycle: role == .parent ? nil : 3)
            try await FirestoreService.shared.addUser(user: newUser)
            UserManager.shared.user = newUser
            navigationManager.push(to: .connectUser)
        } catch {
            // TODO: 오류 처리 로직 추가
        }
    }
}
