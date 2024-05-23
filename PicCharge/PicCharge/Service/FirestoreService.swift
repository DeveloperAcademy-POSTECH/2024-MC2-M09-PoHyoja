//
//  FirestoreService.swift
//  PicCharge
//
//  Created by 이상현 on 5/18/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService {
    
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init(){}
    
    /// 이메일로 Firestore에서 유저 정보 가져오기
    func fetchUserByEmail(email: String) async -> User? {
        do {
            let snapshot = try await db.collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            print("서버에서 \(email) 유저 정보를 찾는다.")
            
            guard let document = snapshot.documents.first else {
                return nil
            }
            
            return try document.data(as: User.self)
        } catch {
            print("유저 데이터 페치 에러: \(error)")
            return nil
        }
    }
    
    /// 이름으로 Firestore에서 유저 정보 가져오기
    func fetchUserByName(name: String) async -> User? {
        do {
            let snapshot = try await db.collection("users")
                .whereField("name", isEqualTo: name)
                .getDocuments()
            
            print("서버에서 \(name) 유저 정보를 찾는다.")
            
            guard let document = snapshot.documents.first else {
                return nil
            }
            
            return try document.data(as: User.self)
        } catch {
            print("유저 데이터 페치 에러: \(error)")
            return nil
        }
    }
    
    /// 서버에 유저 추가
    func addUser(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        
        if try await checkUserExists(userName: user.name) {
            throw FirestoreServiceError.userAlreadyExists
        }
        
        do {
            try db.collection("users").document(userId).setData(from: user)
            print("서버에 유저 추가됨 id: \(userId), data: \(user)")
        } catch {
            throw error
        }
    }
    
    /// 서버에 유저가 존재하는지 이름으로 확인
    func checkUserExists(userName: String) async throws -> Bool {
        guard !userName.isEmpty else {
            throw FirestoreServiceError.invalidUserId
        }
        
        let querySnapshot = try await db.collection("users")
            .whereField("name", isEqualTo: userName)
            .getDocuments()
        
        return !querySnapshot.documents.isEmpty
    }
    
    /// 서버에서 유저 살제
    func deleteUser(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        try await db.collection("users").document(userId).delete()
    }
    
    /// 연결 요청을 Firestore에 추가
    func addConnectRequests(currentUserName: String, otherUserName: String) async throws {
        let connectionRequest = ConnectionRequestsDTO(
            id: nil,
            from: currentUserName,
            to: otherUserName,
            status: .pending,
            requestDate: Date()
        )
        
        // Upload connection request
        try db.collection("connectionRequests").addDocument(from: connectionRequest)
    }
    
    
    /// 특정 사용자에게 온 연결 요청을 Firestore에서 가져오는 메서드
    func fetchConnectionRequests(userName: String) async throws -> [ConnectionRequestsDTO] {
        let snapshot = try await db.collection("connectionRequests")
            .whereField("to", isEqualTo: userName)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        print("페치된 문서: \(snapshot.documents)") // 디버깅을 위해 출력
        
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ConnectionRequestsDTO.self)
            } catch {
                print("문서 디코딩 실패: \(document.data()), error: \(error)")
                return nil
            }
        }
    }
    
    /// 연결 요청을 넘겨준 ConnectionRequestsDTO 로 업데이트하는 메서드
    func updateConnectionRequest(request: ConnectionRequestsDTO) async throws {
        guard let requestId = request.id else {
            throw FirestoreServiceError.invalidRequestId
        }
        
        try db.collection("connectionRequests").document(requestId).setData(from: request)
    }
    
    /// 사용자 연결 정보를 넘겨준 User 로 업데이트하는 메서드
    func updateUserConnections(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        
        try db.collection("users").document(userId).setData(from: user, merge: true)
    }
}
