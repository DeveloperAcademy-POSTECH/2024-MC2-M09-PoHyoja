//
//  ConnectUserView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//
import SwiftUI

struct ConnectUserView: View {
    @Environment(NavigationManager.self) var navigationManager
    @EnvironmentObject private var userManager: UserManager

    @State private var toUserId: String = ""   // 연결을 요청받는 사용자 ID
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Text("유저 연결 화면")
                .font(.largeTitle)
                .padding()
            Text("현재 \(userManager.user?.name ?? "ERROR") (\(userManager.user?.email ?? "ERROR"))로 로그인 되었습니다.")
            TextField("연결할 아이디 입력", text: $toUserId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("연결 요청 보내기") {
                Task {
                    await sendConnectionRequest()
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(toUserId.isEmpty)
            
            Button("연결 승인") {
                Task {
                    await acceptConnectionRequest()
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Button("서버에서 사용자 정보 가져오기") {
                Task {
                    await fetchAndUpdateUserInfo()
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Button("홈으로") {
                navigationManager.popToRoot()
            }
            .padding()
        }
        .padding()
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

    
extension ConnectUserView {
    private func sendConnectionRequest() async {
        guard let currentUser = userManager.user, let userId = currentUser.id else {
            alertMessage = "사용자 ID를 찾을 수 없습니다."
            isShowingAlert = true
            return
        }
        
        do {
            try await FirestoreService.shared.uploadConnectionRequest(from: userId, to: toUserId)
            alertMessage = "연결 요청이 성공적으로 전송되었습니다."
            isShowingAlert = true
        } catch {
            alertMessage = "연결 요청을 전송하는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    private func acceptConnectionRequest() async {
        guard let currentUser = userManager.user, let userId = currentUser.id else {
            alertMessage = "사용자 ID를 찾을 수 없습니다."
            isShowingAlert = true
            return
        }
        
        do {
            let requests = try await FirestoreService.shared.fetchConnectionRequests(for: userId)
            print("Fetched requests: \(requests)")
            guard let request = requests.first(where: { $0.status == .pending }) else {
                alertMessage = "연결 요청을 찾을 수 없습니다."
                isShowingAlert = true
                return
            }
            
            var updatedRequest = request
            updatedRequest.status = .accepted
            try await FirestoreService.shared.updateConnectionRequest(request: updatedRequest)
            print("Updated request: \(updatedRequest)")
            
            let connectedUserId = try await FirestoreService.shared.fetchUser(by: request.from).id!
            print("Fetched connected user: \(connectedUserId)")
            
            var updatedUser = currentUser
            updatedUser.connectedTo.append(connectedUserId)
            userManager.user = updatedUser
            
            try await FirestoreService.shared.updateUserConnections(user: updatedUser)
            
            alertMessage = "연결 요청이 승인되었습니다."
            isShowingAlert = true
        } catch {
            alertMessage = "연결 요청을 승인하는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    private func fetchAndUpdateUserInfo() async {
        guard let currentUser = userManager.user, let userId = currentUser.id else {
            alertMessage = "사용자 ID를 찾을 수 없습니다."
            isShowingAlert = true
            return
        }
        
        do {
            let fetchedUser = try await FirestoreService.shared.fetchUser(by: userId)
            DispatchQueue.main.async {
                userManager.user = fetchedUser
            }
            alertMessage = "사용자 정보가 성공적으로 업데이트되었습니다."
            isShowingAlert = true
        } catch {
            alertMessage = "사용자 정보를 가져오는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
}
