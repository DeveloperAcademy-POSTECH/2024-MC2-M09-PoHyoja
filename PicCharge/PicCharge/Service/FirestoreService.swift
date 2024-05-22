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
    
    private init(){}
    
    private let db = Firestore.firestore()
    
    func fetchPhotos(user: User) async throws -> [Photo]? {
        return []
    }
    
    private func filterPhotos(by snapShot: QuerySnapshot, userId: String) throws -> [Photo]? {
        return []
    }
    
    // TODO: Photo 대신에 Image 를 받는 등 로직 개선 필요함
    // TODO: Firebase Storage 연결
    func addPhoto(child: User, parent: User, imageData: Data) async throws {
    }
    
    private func validatePhoto(child: User, parent: User, photo: Photo) -> Bool {
        return false
    }
    
    func updatePhotoLikeCount(user: User, of photo: Photo, by plusLikeCount: Int) async throws {
    }
    
    func deletePhoto(photo: Photo) async throws {
    }
    
    func fetchSerchedUsers(searchUserId: String) async throws -> [User] {
        return []
    }
    
    // 사용자 정보를 Firestore에서 가져오는 메서드
    func fetchUser(by userName: String) async throws -> User {
        let snapshot = try await db.collection("users").whereField("name", isEqualTo: userName).getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw FirestoreServiceError.userNotFound
        }
        
        guard let user = try? document.data(as: User.self) else {
            throw FirestoreServiceError.userNotFound
        }
        
        return user
    }
    
    
    func addUser(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        
        if try await checkUserExists(userName: user.name) {
            throw FirestoreServiceError.userAlreadyExists
        }
        
        try db.collection("users").document(userId).setData(from: user)
        print("User added with id: \(userId), data: \(user)")
    }
    
    func checkUserExists(userName: String) async throws -> Bool {
        guard !userName.isEmpty else {
            throw FirestoreServiceError.invalidUserId
        }
        
        let querySnapshot = try await db.collection("users")
            .whereField("name", isEqualTo: userName)
            .getDocuments()
        
        return !querySnapshot.documents.isEmpty
    }
    
    func deleteUser(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        try await db.collection("users").document(userId).delete()
    }
    
    /// 연결 요청을 Firestore에 업로드하는 메서드
    func addConnectRequests(from currentUserName: String, to otherUserName: String) async throws {
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
    
    
    private func uploadConnectionRequest(request: ConnectionRequestsDTO) async throws {
        try db.collection("connectionRequests").addDocument(from: request)
    }
    
    ///
    func fetchConnectionStatus(user: User) async throws -> ConnectionRequestStatus {
        return .accepted
    }
    
    
    /// 특정 사용자의 연결 요청을 Firestore에서 가져오는 메서드
    func fetchConnectionRequests(for userName: String) async throws -> [ConnectionRequestsDTO] {
        let snapshot = try await db.collection("connectionRequests")
            .whereField("to", isEqualTo: userName)
            .getDocuments()
        
        print("Fetched documents: \(snapshot.documents)") // 디버깅을 위해 출력
        
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ConnectionRequestsDTO.self)
            } catch {
                print("Failed to decode document: \(document.data()), error: \(error)")
                return nil
            }
        }
    }
    
    /// 연결 요청을 업데이트하는 메서드
    func updateConnectionRequest(request: ConnectionRequestsDTO) async throws {
        guard let requestId = request.id else {
            throw FirestoreServiceError.invalidRequestId
        }
        
        try db.collection("connectionRequests").document(requestId).setData(from: request)
    }
    
    /// 사용자 연결 정보를 업데이트하는 메서드
    func updateUserConnections(user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        
        try db.collection("users").document(userId).setData(from: user, merge: true)
    }
}
