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
    
    @State private var requestToMe: ConnectionRequestsDTO? = nil
    @State private var requestFromMe: ConnectionRequestsDTO? = nil
    @State private var nameInput: String = ""
    @State private var isNetworking: Bool = false
    @State private var isConnected: Bool = false
    @State private var buggungEnd: Bool = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    init(user: UserForSwiftData) {
        self.user = user
    }
    
    var body: some View {
        Group {
            if isConnected {
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
            } else {
                if let requestFromMe = requestFromMe {
                    WaitingView(request: requestFromMe)
                } else {
                    if let requestToMe = requestToMe {
                        AcceptView(request: requestToMe)
                    } else {
                        SearchNameView()
                    }
                }
            }
        }
        .task {
            if let request = await fetchWaitingRequest() {
                listenRequest(from: user.name)
            } else {
                listenRequest(to: user.name)
            }
        }
        .onDisappear {
            FirestoreService.shared.removeListener()
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    @ViewBuilder
    func AcceptView(request: ConnectionRequestsDTO) -> some View {
        ZStack {
            VStack(spacing: 8) {
                Spacer()
                
                Button {
                    Task {
                        isNetworking = true
                        listenRequest(to: user.name)
                        await rejectConnectionRequest(request: request)
                        isNetworking = false
                    }
                } label: {
                    ZStack {
                        Color.gray
                        
                        if isNetworking {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("거절")
                                .bold()
                                .font(.title3)
                                .foregroundStyle(.txtPrimaryDark)
                        }
                    }
                }
                .frame(height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(isNetworking)
                
                Button {
                    Task {
                        isNetworking = true
                        await acceptConnectionRequest(currentUserName: user.name, request: request)
                        isConnected = true
                        isNetworking = false
                    }
                } label: {
                    ZStack {
                        Color.green
                        
                        if isNetworking {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("수락")
                                .bold()
                                .font(.title3)
                                .foregroundStyle(.txtPrimaryDark)
                        }
                    }
                }
                .frame(height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 16)
                .disabled(isNetworking)
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                Icon.person
                    .font(.system(size: 64))
                    .foregroundStyle(.gray)
                    .padding(.bottom, 8)
                
                VStack {
                    Text("\(user.name)님!")
                    Text("\(request.from)님에게서")
                    Text("연결 요청이 왔습니다")
                }
                .foregroundStyle(.txtPrimaryDark)
                .font(.title2.bold())
                .padding(.bottom, 32)
                
                Text(" ").font(.headline)
            }
        }
    }
    
    @ViewBuilder
    func WaitingView(request: ConnectionRequestsDTO) -> some View {
        VStack(spacing: 0) {
            Icon.waitingPerson
                .font(.system(size: 64))
                .foregroundStyle(.gray)
                .padding(.bottom, 8)
            
            VStack {
                Text("\(user.name)님!")
                Text("\(request.to)님에게")
                Text("연결 요청 되었습니다")
            }
            .foregroundStyle(.txtPrimaryDark)
            .font(.title2.bold())
            .padding(.bottom, 32)
            
            Text("상대방이 수락할 때까지 잠시만 기다려주세요")
                .foregroundStyle(.txtPrimaryDark)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    func SearchNameView() -> some View {
        VStack(alignment: .leading) {
            Text("\(user.name)님, 가족의 이름을 알려주세요")
                .font(.title2.bold())
                .foregroundStyle(.txtPrimaryDark)
                .padding(.top, 40)
            
            VStack(spacing: 8) {
                TextField("가족 이름을 알려주세요", text: $nameInput)
                    .autocapitalization(.none)
                    .foregroundStyle(.txtPrimaryDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.bgPrimaryElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Spacer()
            
            Button {
                Task {
                    isNetworking = true
                    listenRequest(from: user.name)
                    await sendConnectionRequest(currentUserName: user.name, otherUserName: nameInput)
                    isNetworking = false
                }
            } label: {
                ZStack {
                    nameInput.isEmpty ? Color.gray : Color.green
                    
                    Text("연결하기")
                        .bold()
                        .font(.title3)
                        .foregroundStyle(.txtPrimaryDark)
                }
            }
            .frame(height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 16)
            .disabled(nameInput.isEmpty)
        }
        .padding(.horizontal, 16)
    }
    
    
}


extension ConnectUserView {
    private func sendConnectionRequest(currentUserName: String, otherUserName: String) async {
        do {
            let userExists = try await FirestoreService.shared.checkUserExists(userName: otherUserName)
            
            guard userExists else {
                alertMessage = "해당 사용자를 찾을 수 없습니다."
                isShowingAlert = true
                requestFromMe = nil
                return
            }
            
            try await FirestoreService.shared.addConnectRequests(currentUserName: user.name, otherUserName: otherUserName)
            
        } catch {
            print("연결 요청을 전송하는데 실패했습니다: \(error.localizedDescription)")
            requestFromMe = nil
            return
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
            
            print("연결 요청이 승인되었습니다.")
        } catch {
            alertMessage = "연결 요청을 승인하는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    private func rejectConnectionRequest(request: ConnectionRequestsDTO) async {
        do {
            var updatedRequest = request
            updatedRequest.status = .rejected // 거절 상태로 변경
            
            print(updatedRequest)
            // 연결 요청 거절하고 파이어베이스의 ConnectionRequests 업데이트
            try await FirestoreService.shared.updateConnectionRequest(request: updatedRequest)
            
            print("연결 요청이 거절되었습니다.")
            requestToMe = nil
            
        } catch {
            alertMessage = "연결 요청을 거절하는데 실패했습니다: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    
    private func fetchWaitingRequest() async -> ConnectionRequestsDTO? {
        do {
            // 기다리는 요청 찾기
            let waitingRequests = try await FirestoreService.shared.fetchConnectionRequests(userName: user.name)
        
            // 가장 최신 연결 요청 찾기, 없으면 반환
            guard let recentRequest = waitingRequests.max(by: { $0.requestDate < $1.requestDate }) else {
                return nil
            }
            
            return recentRequest
        } catch {
            return nil
        }
    }
    
    private func listenRequest(to user: String) {
        FirestoreService.shared.listenRequest(to: user) { result in
            switch result {
            case .success(let connections):
                guard let recentRequest = connections.max(by: { $0.requestDate < $1.requestDate }) else {
                    return
                }
                
                requestToMe = recentRequest
            case .failure:
                print("FireStore 실시간 데이터 오류")
            }
        }
    }
    
    private func listenRequest(from user: String) {
        FirestoreService.shared.listenRequest(from: user) { result in
            switch result {
            case .success(let connections):
                guard let recentRequest = connections.max(by: { $0.requestDate < $1.requestDate }) else {
                    return
                }
                
                switch recentRequest.status {
                case .pending:
                    requestFromMe = recentRequest
                case .accepted:
                    self.user.connectedTo.append(recentRequest.to)
                    isConnected = true
                case .rejected:
                    requestFromMe = nil
                    listenRequest(to: user)
                }
                
            case .failure:
                print("FireStore 실시간 데이터 오류")
            }
        }
    }
}
