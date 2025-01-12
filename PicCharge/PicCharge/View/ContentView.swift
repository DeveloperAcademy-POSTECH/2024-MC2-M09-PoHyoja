//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI
import SwiftData
import FirebaseAuth
import WidgetKit

enum UserState {
    case checkNeeded
    case notConnected
    case connectedChild
    case connectedParent
    case notExist
}

struct ContentView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    @Environment(PhotoViewModel.self) var photoVM
    
    // TODO: - 제거
    @Environment(\.modelContext) var modelContext
    @Query var userForSwiftDatas: [UserEntity]
    
    @State private var isFirstLoad = true
    @State private var buggungEnd = false
    
    var body: some View {
        Group {
            switch navigationManager.userState {
            case .notExist:
                LoginView()
            case .notConnected:
                ConnectUserView(user: UserEntity(userVM.user!))
            case .connectedChild:
                ChildTabView()
            case .connectedParent:
                ParentAlbumView()
            default:
                if buggungEnd {
                    BuggungEndView()
                } else {
                    BuggungLoadingView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    buggungEnd = true
                                }
                            }
                        }
                }
            }
        }
        .task {
            if isFirstLoad {
                await startProcess()
                isFirstLoad = false
            }
        }
    }
}

extension ContentView {
    private func startProcess() async {
        let startTime = Date()
        
        Task {
            let state = checkLoginStatus()
            
            switch state {
            case .connectedChild, .connectedParent:
                await photoVM.syncPhoto(of: userVM.user?.name ?? "자식")
                WidgetCenter.shared.reloadAllTimelines()
            default:
                break
            }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            let delay = max(0, 2.5 - elapsedTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    navigationManager.userState = state
                }
            }
        }
    }
    
    private func checkLoginStatus() -> UserState {
        // 자동로그인 확인
        guard let _ = Auth.auth().currentUser else {
            print("자동로그인 불가능")
            
            for userForSwiftData in self.userForSwiftDatas {
                modelContext.delete(userForSwiftData)
            }
            return .notExist
        }
        
        // 로컬데이터 확인
        guard let swiftDataUser = userForSwiftDatas.first else {
            print("로컬에 유저 데이터 없음")
            return .notExist
        }
        
        // 로컬데이터 에서 연결된 사람 있는지 확인
        guard !swiftDataUser.connectedTo.isEmpty else {
            print("로컬 유저 데이터에 연결된 사람 없음")
            return .notConnected
        }
        
        print("--swiftDataUser 정보--")
        print("name: \(swiftDataUser.name)")
        print("role: \(swiftDataUser.role)")
        print("email: \(swiftDataUser.email)")
        print("connectedTo: \(swiftDataUser.connectedTo)")
        print("uploadCycle: \(swiftDataUser.uploadCycle ?? 0)")
        
        // 역할에 따라 적절한 뷰로 이동
        switch swiftDataUser.role {
        case .child:
            print("유저정보 확인: child 역할")
            return .connectedChild
        case .parent:
            print("유저정보 확인: parent 역할")
            return .connectedParent
        }
    }
}
