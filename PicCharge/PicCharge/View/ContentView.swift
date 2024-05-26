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
    
    @Query var userForSwiftDatas: [UserForSwiftData]
    @Query(sort: \PhotoForSwiftData.uploadDate, order: .reverse) var photoForSwiftDatas: [PhotoForSwiftData]
    
    @State private var isAppearing: Bool = true
    @State private var isFirstLoad = true
    @State private var buggungEnd = false
    
    var user: UserForSwiftData {
        userForSwiftDatas.first ?? UserForSwiftData(name: "", role: .child, email: "")
    }
    
    var body: some View {
        Group {
            switch navigationManager.userState {
            case .notExist:
                LoginView()
            case .notConnected:
                ConnectUserView(user: user)
            case .connectedChild:
                ChildTabView(user: user)
                    .transition(.opacity.animation(.easeInOut(duration: 1)))
                    .onAppear {
                        withAnimation {
                            isAppearing = false
                        }
                    }
            case .connectedParent:
                ParentAlbumView(user: user)
            default:
                if buggungEnd {
                    BuggungEndView()
                        .transition(.opacity.animation(.easeInOut(duration: 1)))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                navigationManager.userState = (user.role == .child) ? .connectedChild : .connectedParent
                            }
                        }
                } else {
                    BuggungLoadingView()
                        .transition(.opacity.animation(.easeInOut(duration: 1)))
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
        .transition(.opacity)
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
                await syncPhotoData()
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
    
    private func syncPhotoData() async {
        var updateCount = 0
        var addCount = 0
        var deleteCount = 0
        
        guard let swiftDataUser = userForSwiftDatas.first else {
            print("로컬에 유저 데이터 없음")
            return
        }
        
        do {
            let photos = try await FirestoreService.shared.fetchPhotos(userName: swiftDataUser.name)
            var photoIds = Set<UUID>()
            
            for photo in photos {
                
                guard let photoIdString = photo.id,
                      let photoId = UUID(uuidString: photoIdString)
                else {
                    print("유효하지 않은 ID: \(String(describing: photo.id))")
                    continue
                }
                
                photoIds.insert(photoId)
                
                if let existingPhoto = photoForSwiftDatas.first(where: { $0.id == photoId }) {
                    if existingPhoto.likeCount != photo.likeCount {
                        updateCount += 1
                        existingPhoto.likeCount = photo.likeCount
                    }
                } else {
                    addCount += 1
                    let newPhotoForSwiftData = try await FirestoreService.shared.fetchPhotoForSwiftDataByPhoto(photo: photo)
                    modelContext.insert(newPhotoForSwiftData)
                }
            }
            
            for photoForSwiftData in photoForSwiftDatas {
                if !photoIds.contains(photoForSwiftData.id) {
                    deleteCount += 1
                    modelContext.delete(photoForSwiftData)
                }
            }
            
            try modelContext.save()
            
            print("총\(photos.count) 개의 이미지")
            print("\(updateCount + addCount + deleteCount) 개의 이미지 동기화함")
            print("\(updateCount) 개의 사진 업데이트됨")
            print("\(addCount) 개의 사진 추가됨")
            print("\(deleteCount) 개의 사진 삭제됨")
            
        } catch {
            print("사진 데이터 동기화 실패: \(error)")
        }
    }
}
