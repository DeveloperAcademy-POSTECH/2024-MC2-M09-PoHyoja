//
//  ConnectUserView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//
import SwiftUI
import FirebaseAuth

struct ConnectUserView: View {
    @Environment(NavigationManager.self) var navigationManager
//    @EnvironmentObject private var userManager: UserManager
//    @EnvironmentObject private var authViewModel: AuthViewModel
//    
//    @State private var otherUserName: String = ""   // 연결을 요청받는 사용자 ID
//    @State private var isShowingAlert = false
//    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Text("유저 연결 화면")
//            Text("유저 연결 화면")
//                .font(.largeTitle)
//                .padding()
//            Text("현재 \(userManager.user?.name ?? "ERROR") (\(userManager.user?.email ?? "ERROR"))로 로그인 되었습니다.")
//            TextField("연결할 아이디 입력", text: $otherUserName)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            Button("연결 요청 보내기") {
//                Task {
//                    await sendConnectionRequest()
//                }
//            }
//            .padding()
//            .buttonStyle(.borderedProminent)
//            .disabled(otherUserName.isEmpty)
//            
//            Button("연결 승인") {
//                Task {
//                    await acceptConnectionRequest()
//                }
//            }
//            .padding()
//            .buttonStyle(.borderedProminent)
//            
//            Button("서버에서 사용자 정보 가져오기") {
//                Task {
//                    await fetchAndUpdateUserInfo()
//                }
//            }
//            .padding()
//            .buttonStyle(.borderedProminent)
//            
//            Spacer()
//            
            Button("로그아웃") {
                signOut()
                navigationManager.popToRoot()
            }
//            .padding()
//            .buttonStyle(.bordered)
//            
//            Button("회원 탈퇴") {
//                Task {
//                    await deleteUser()
//                }
//            }
//            .padding()
//            .buttonStyle(.bordered)
//            .foregroundColor(.red)
//        }
//        .padding()
//        .onReceive(authViewModel.$user) { user in
//            self.userManager.user = user
//        }
//        .alert(isPresented: $isShowingAlert) {
//            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}


extension ConnectUserView {
//    private func sendConnectionRequest() async {
//        guard let currentUser = userManager.user else {
//            alertMessage = "사용자 ID를 찾을 수 없습니다."
//            isShowingAlert = true
//            return
//        }
//        
//        do {
//            let userExists = try await FirestoreService.shared.checkUserExists(userName: otherUserName)
//            if !userExists {
//                alertMessage = "해당 사용자를 찾을 수 없습니다."
//                isShowingAlert = true
//                return
//            }
//        } catch {
//            alertMessage = "사용자 아이디가 비어있습니다."
//            isShowingAlert = true
//            return
//        }
//        
//        do {
//            try await FirestoreService.shared.addConnectRequests(from: currentUser.name, to: otherUserName)
//            alertMessage = "연결 요청이 성공적으로 전송되었습니다."
//            isShowingAlert = true
//        } catch {
//            alertMessage = "연결 요청을 전송하는데 실패했습니다: \(error.localizedDescription)"
//            isShowingAlert = true
//        }
//    }
//    
//    
//    /*
//     뷰에서 버튼을 누르면
//     이번엔 수락하는 쪽에서 connectionRequests 를 보고 본인의 아이디가 to 에 있으면,
//     1. 본인의 로컬의 User의 connectedTo 도 업데이트
//     2. 파이어베이스의 User 도 업데이트
//     3. 파이어베이스의 ConnectionRequests 업데이트
//     */
//    private func acceptConnectionRequest() async {
//        guard let currentUser = userManager.user, let userId = currentUser.id else {
//            alertMessage = "현재 사용자 ID를 찾을 수 없습니다."
//            isShowingAlert = true
//            return
//        }
//        
//        do {
//            // 연결 요청 찾기
//            let requests = try await FirestoreService.shared.fetchConnectionRequests(for: userId)
//            print("Fetched requests: \(requests)")
//            guard let request = requests.first(where: { $0.status == .pending }) else {
//                alertMessage = "연결 요청을 찾을 수 없습니다."
//                isShowingAlert = true
//                return
//            }
//            
//            var updatedRequest = request
//            updatedRequest.status = .accepted
//            // 연결 요청 수락하고 3. 파이어베이스의 ConnectionRequests 업데이트
//            try await FirestoreService.shared.updateConnectionRequest(request: updatedRequest)
//            print("Updated request: \(updatedRequest)")
//            
//            // 연결한 유저 정보 받아오기
//            let otherUser = try await FirestoreService.shared.fetchUser(by: request.from)
//            print("Fetched connected user: \(otherUser.name)")
//            
//            // 1. 본인의 로컬의 User의 connectedTo 업데이트
//            var updatedUser = currentUser
//            updatedUser.connectedTo.append(otherUser.name)
//            var updatedOtherUser = otherUser
//            updatedOtherUser.connectedTo.append(currentUser.name)
//            userManager.user = updatedUser
//            
//            // 2. 파이어베이스의 본인 User 정보도 업데이트
//            try await FirestoreService.shared.updateUserConnections(user: updatedUser)
//            
//            // 4. 파이어베이스의 상대방 (요청 보낸) User 정보도 업데이트
//            try await FirestoreService.shared.updateUserConnections(user: updatedOtherUser)
//            
//            alertMessage = "연결 요청이 승인되었습니다."
//            isShowingAlert = true
//        } catch {
//            alertMessage = "연결 요청을 승인하는데 실패했습니다: \(error.localizedDescription)"
//            isShowingAlert = true
//        }
//    }
//    
//    private func fetchAndUpdateUserInfo() async {
//        guard let currentUser = userManager.user else {
//            print("로컬에서 유저 찾기 실패")
//            alertMessage = "사용자 ID를 찾을 수 없습니다."
//            isShowingAlert = true
//            return
//        }
//        
//        print(currentUser)
//        let userName = currentUser.name
//        print(userName)
//        
//        do {
//            let fetchedUser = try await FirestoreService.shared.fetchUser(by: userName)
//            DispatchQueue.main.async {
//                userManager.user = fetchedUser
//            }
//            alertMessage = "사용자 정보가 성공적으로 업데이트되었습니다."
//            isShowingAlert = true
//        } catch {
//            alertMessage = "사용자 정보를 가져오는데 실패했습니다: \(error.localizedDescription)"
//            isShowingAlert = true
//        }
//    }
//
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("로그아웃 실패")
        }
    }
//
//    private func deleteUser() async {authViewModel.deleteUser { error in
//        if let error = error {
//            alertMessage = "회원 탈퇴에 실패했습니다: \(error.localizedDescription)"
//            isShowingAlert = true
//        } else {
//            alertMessage = "성공적으로 회원 탈퇴되었습니다."
//            isShowingAlert = true
//        }
//    }
//    }
}
