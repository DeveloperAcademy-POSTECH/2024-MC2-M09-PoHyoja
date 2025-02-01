//
//  ContentView.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(UserViewModel.self) var userVM
    @Environment(PhotoViewModel.self) var photoVM
    
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                BuggungLoadingView()
                
            } else {
                switch userVM.state {
                    
                case .notExist:
                    MainLoginView()
                    
                case .notConnected:
                    ConnectUserView()
                    
                case .connected(let role) where role == .parent:
                    ParentAlbumView()
                    
                case .connected(let role) where role == .child:
                    ChildTabView()
                    
                default:
                    EmptyView()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { isLoading = false }
            }
        }
        .onOpenURL { url in
            guard url.scheme == "widget" else { return }
            
            if let route = url.queryItems?["route"] {
                switch route {
                case "gallery":
                    Task {
                        await userVM.checkUserState()
                        if userVM.state == .connected(.child) && navigationManager.path.isEmpty {
                            navigationManager.push(to: .childSendGallery)
                        }
                    }
                default:
                    print("Unknown deeplink: \(url)")
                }
            }
        }
        .task {
            // 1. 유저 Auth 상태 체크
            await userVM.checkUserState()
            
            // 2. 유저 연결여부 확인
            guard let user = userVM.user, user.isConnected
            else { return }
            
            // 3. 사진 데이터 동기화
            await photoVM.syncPhoto(of: user.name)
            
            // 4. 위젯 리로드
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

