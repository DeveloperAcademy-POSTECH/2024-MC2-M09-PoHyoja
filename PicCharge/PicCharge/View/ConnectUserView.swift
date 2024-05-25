//
//  ConnectUserView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//
import SwiftUI
import FirebaseAuth
import SwiftData

struct ConnectUserView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Bindable var user: UserForSwiftData
    
    @State private var otherUserName: String = ""   // 연결을 요청받는 사용자 ID
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var connectionRequest: ConnectionRequestsDTO?

    var body: some View {
        VStack {
            Text("유저 연결 화면")
                .font(.largeTitle)
                .padding()
            Text("현재 \(user.name)로 로그인 되었습니다.")
            TextField("연결할 아이디 입력", text: $otherUserName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("연결 요청 보내기") {
                Task {
                    await sendConnectionRequest(currentUserName: user.name, otherUserName: otherUserName)
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(otherUserName.isEmpty)
            
            if let request = connectionRequest {
                Text("연결 요청: \(request.from)")
                
                HStack {
                    Button("연결 승인") {
                        Task {
                            await acceptConnectionRequest(currentUserName: user.name, request: request)
                            navigationManager.popToRoot()
                        }
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    
                    Button("연결 거절") {
                        Task {
                            await rejectConnectionRequest(request: request)
                        }
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
            
            // TODO: 연결 거절 버튼
            
            Button("새로고침 (연결 요청 있는지 확인)") {
                Task {
                    await refreshConnectionRequest()
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            // TODO: 개발 완료 시 아래 버튼들 모두 지워야 함
            Button("[TEST]로그아웃") {
                logout()
                navigationManager.popToRoot()
            }
            .padding()
            .buttonStyle(.bordered)
            
            Button("[TEST]자식 메인 뷰 이동") {
                navigationManager.push(to: .childMain)
            }
            .padding()
            .buttonStyle(.bordered)
            
            Button("[TEST]부모 앨범 뷰 이동") {
                navigationManager.push(to: .parentAlbum)
            }
            .padding()
            .buttonStyle(.bordered)
        }
        .padding()
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}


extension ConnectUserView {
    private func sendConnectionRequest(currentUserName: String, otherUserName: String) async {
        do {
            let userExists = try await FirestoreService.shared.checkUserExists(userName: otherUserName)
            if !userExists {
                alertMessage = "해당 사용자를 찾을 수 없습니다."
                isShowingAlert = true
                return
            }
        } catch { // from 이 nil일 경우
            alertMessage = "사용자 아이디가 비어있습니다."
            isShowingAlert = true
            return
        }
        
        do {
            try await FirestoreService.shared.addConnectRequests(currentUserName: user.name, otherUserName: otherUserName)
            alertMessage = "연결 요청이 성공적으로 전송되었습니다."
            isShowingAlert = true
        } catch {
            alertMessage = "연결 요청을 전송하는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    
    private func acceptConnectionRequest(currentUserName: String, request: ConnectionRequestsDTO) async {
        do {
            var updatedRequest = request
            updatedRequest.status = .accepted // 수락 상태로 변경
            
            // 연결 요청 수락하고 파이어베이스의 ConnectionRequests 업데이트
            try await FirestoreService.shared.updateConnectionRequest(request: updatedRequest)
            print("업데이트한 request: \(updatedRequest)")
            
            // 연결한 유저 정보 받아오기
            guard var otherUser = await FirestoreService.shared.fetchUserByName(name: request.from) else {
                alertMessage = "연결 요청한 유저를 찾을 수 없습니다."
                isShowingAlert = true
                return
            }
            print("연결된 유저: \(String(describing: otherUser.name))")
            
            // 파이어베이스의 상대방 (요청 보낸) User 정보도 업데이트
            otherUser.connectedTo.append(user.name)
            try await FirestoreService.shared.updateUserConnections(user: otherUser)
            
            // 본인의 로컬의 User의 connectedTo 업데이트
            
            user.connectedTo.append(otherUser.name)
            
            // 파이어베이스의 본인 User 정보 업데이트
            guard var firebaseUser = await FirestoreService.shared.fetchUserByName(name: user.name) else {
                print("서버에서 \(user.name): \(user.email)의 정보를 가져오지 못했습니다.")
                return
            }
            firebaseUser.connectedTo.append(otherUser.name)
            try await FirestoreService.shared.updateUserConnections(user: firebaseUser)
            
            alertMessage = "연결 요청이 승인되었습니다."
            isShowingAlert = true
        } catch {
            alertMessage = "연결 요청을 승인하는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    private func rejectConnectionRequest(request: ConnectionRequestsDTO) async {
        do {
            var updatedRequest = request
            updatedRequest.status = .rejected // 거절 상태로 변경
            
            // 연결 요청 거절하고 파이어베이스의 ConnectionRequests 업데이트
            try await FirestoreService.shared.updateConnectionRequest(request: updatedRequest)
            
            alertMessage = "연결 요청이 거절되었습니다."
            isShowingAlert = true
            connectionRequest = nil
        } catch {
            alertMessage = "연결 요청을 거절하는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    private func refreshConnectionRequest() async {
        do {
            // 연결 요청 찾기
            let requests = try await FirestoreService.shared.fetchConnectionRequests(userName: user.name)
            
            // 가장 최신 연결 요청 찾기, 없으면 반환
            guard let recentRequest = requests.max(by: { $0.requestDate < $1.requestDate }) else {
                alertMessage = "연결 요청을 찾을 수 없습니다."
                isShowingAlert = true
                connectionRequest = nil
                return
            }
            
            // 최신 연결 요청 저장
            connectionRequest = recentRequest
        } catch {
            alertMessage = "연결 요청을 새로고침하는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            alertMessage = "로그아웃에 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
            return
        }
        alertMessage = "성공적으로 로그아웃되었습니다."
        isShowingAlert = true
    }
}
