//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI
import SwiftData
import FirebaseAuth

enum UserState {
    case checkNeeded
    case notConnected
    case connectedChild
    case connectedParent
    case notExist
}

struct ContentView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(\.modelContext) var modelContext
    @State private var userState: UserState = .checkNeeded
    @Query var userForSwiftDatas: [UserForSwiftData]
    
    var body: some View {
        Group {
            switch userState {
            case .notExist:
                LoginView(userState: $userState)
            case .notConnected:
                ConnectUserView(user: userForSwiftDatas.first!)
            case .connectedChild:
                ChildTabView()
            case .connectedParent:
                ParentAlbumView()
            default:
                LoginView(userState: $userState)
            }
        }
        .task {
            await checkLoginStatus()
        }
    }
    
    private func checkLoginStatus() async {
        // 자동로그인 확인
        guard let _ = Auth.auth().currentUser else {
            print("자동로그인 불가능")
            userState = .notExist
            for userForSwiftData in self.userForSwiftDatas {
                modelContext.delete(userForSwiftData)
            }
            return
        }
        
        // 로컬데이터 확인
        guard let swiftDataUser = userForSwiftDatas.first else {
            print("로컬에 유저 데이터 없음")
            userState = .notExist
            return
        }
        print("--swiftDataUser 정보--")
        print("name: \(swiftDataUser.name)")
        print("role: \(swiftDataUser.role)")
        print("email: \(swiftDataUser.email)")
        print("connectedTo: \(swiftDataUser.connectedTo)")
        print("uploadCycle: \(swiftDataUser.uploadCycle ?? 0)")
        
        // 로컬데이터 에서 연결된 사람 있는지 확인
        if swiftDataUser.connectedTo.isEmpty {
            print("로컬 유저 데이터에 연결된 사람 없음")
            userState = .notConnected
            return
        }
        // 역할에 따라 적절한 뷰로 이동
        switch swiftDataUser.role {
        case .child:
            print("유저정보 확인: child 역할")
            userState = .connectedChild
        case .parent:
            print("유저정보 확인: parent 역할")
            userState = .connectedParent
        }
    }
    
    // let user = await await FirestoreService.shared.fetchUserByEmail(email: currentUser.email ?? "") // 유저 정보 서버와 동기화
}

