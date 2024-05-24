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
    
    @State private var isAppearing: Bool = true
    
    var body: some View {
        Group {
            switch userState {
            case .notExist:
                LoginView(userState: $userState)
            case .notConnected:
                ConnectUserView(user: userForSwiftDatas.first!)
            case .connectedChild:
                ChildTabView()
                    .transition(.opacity.animation(.easeInOut(duration: 1)))
                    .onAppear {
                        withAnimation {
                            isAppearing = false
                        }
                    }
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
        guard let authUser = Auth.auth().currentUser else {
            print("authUser 없음")
            userState = .notExist
            for userForSwiftData in self.userForSwiftDatas {
                modelContext.delete(userForSwiftData)
            }
            return
        }
        
        guard let swiftDataUser = userForSwiftDatas.first else {
            print("authUser 있고 swiftDataUser 없음")
            userState = .notExist
            return
        }
        print("--swiftDataUser 정보--")
        print("name: \(swiftDataUser.name)")
        print("role: \(swiftDataUser.role)")
        print("email: \(swiftDataUser.email)")
        print("connectedTo: \(swiftDataUser.connectedTo)")
        print("uploadCycle: \(swiftDataUser.uploadCycle ?? 0)")


        
        if swiftDataUser.connectedTo.isEmpty {
            print("authUser 있고 swiftDataUser 있고 연결안됨")
            userState = .notConnected
            return
        }

        if swiftDataUser.role == .child {
            print("유저정보 확인: child 역할")
            userState = .connectedChild
        }
        
        if swiftDataUser.role == .parent {
            print("유저정보 확인: parent 역할")
            userState = .connectedParent
        }
// let user = await await FirestoreService.shared.fetchUserByEmail(email: currentUser.email ?? "")
    }
}

