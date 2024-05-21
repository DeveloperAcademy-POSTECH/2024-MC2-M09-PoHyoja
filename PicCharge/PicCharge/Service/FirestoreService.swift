//
//  NewFirestoreService.swift
//  PicCharge
//
//  Created by 이상현 on 5/19/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService: FirestoreServiceProtocol {
    
    static let shared = FirestoreService()
    
    private init(){}
    
    private let db = Firestore.firestore()
    
    func fetchPhotos(user: User) async throws -> [Photo]? {
//        guard let userId = user.id else {
//            throw FirestoreServiceError.invalidUserId
//        }
//        
//        let snapShot: QuerySnapshot
//        
//        switch user.role {
//        case Role.child:
//            snapShot = try await db.collection("photos").whereField("uploadBy", isEqualTo: userId).getDocuments()
//            
//        case Role.parent:
//            snapShot = try await db.collection("photos").whereField("sharedWith", arrayContains: userId).getDocuments()
//        }
//        
//        return try filterPhotos(by: snapShot, userId: userId)
        return []
    }
    
    private func filterPhotos(by snapShot: QuerySnapshot, userId: String) throws -> [Photo]? {
        //        if snapShot.isEmpty {
        //            return nil
        //        }
        //        
        //        var photoDTOs: [PhotoDTO] = []
        //        var seenIds = Set<String>()
        //        
        //        let photos = snapShot.documents.compactMap { document -> (PhotoDTO)? in
        //            guard let photoDTO = try? document.data(as: PhotoDTO.self), let id = photoDTO.id else {
        //                return nil
        //            }
        //            
        //            if !seenIds.contains(id) {
        //                seenIds.insert(id)
        //                photoDTOs.append(photoDTO)
        //            }
        //        }
        //        
        //        return try photoDTOs.compactMap { dto -> Photo in
        //            do {
        //                return try Photo(from: dto)
        //            } catch FirestoreServiceError.invalidUUID {} // 오류 발생 시 사진 추가 안함
        //        }
        return []
    }
    
    // TODO: Photo 대신에 Image 를 받는 등 로직 개선 필요함
    // TODO: Firebase Storage 연결
    func addPhoto(child: User, parent: User, imageData: Data) async throws {
        //        guard let childID = child.id, let parentID = parent.id else {
        //            throw FirestoreServiceError.invalidUserId
        //        }
        //        let photoDTO = PhotoDTO(photo: imageData, sharedWith: [parentID])
        //        try db.collection("photos").addDocument(from: photoDTO)
    }
    
    private func validatePhoto(child: User, parent: User, photo: Photo) -> Bool {
        //        if photo.uploadBy != child.id {
        //            return false// TODO: 예외 처리로 로직 변경
        //        }
        return false
    }
    
    func updatePhotoLikeCount(user: User, of photo: Photo, by plusLikeCount: Int) async throws {
//        let photoSnapshot = try await db.collection("photos").document(photo.id.uuidString).getDocument()
//        guard let photoData = photoSnapshot.data() else {
//            throw FirestoreServiceError.documentNotFound
//        }
//        
//        guard let photo = try? photoSnapshot.data(as: PhotoDTO.self) else {
//            return // TODO: 예외 발생으로 변경
//            //throw FirestoreServiceError.decodingError
//        }
    }
    
    func deletePhoto(photo: Photo) async throws {
//        let photoId = photo.id
        //        try await db.collection("photos").document(photoId.uuidString).delete()
        // TODO: 사진이 공유된 사람들만 삭제 가능
    }
    
    func fetchSerchedUsers(searchUserId: String) async throws -> [User] {
        //        let document = try await db.collection("users")
        //            .whereField("role", isEqualTo: Role.child.rawValue) // TODO: Rold.child 대신 유저의 역할 가져와서 반대 역할 검색해야 함
        //            .start(at: [searchUserId])
        //            .end(at: [searchUserId + "\u{f8ff}"])
        //            .getDocuments()
        //        
        //        guard !document.isEmpty else {
        //            throw FirestoreServiceError.userNotFound
        //        }
        //        
        //        let users = document.documents.compactMap { document -> (User)? in
        //            guard let userDTO = try? document.data(as: UserDTO.self) else {
        //                return nil // TODO: 예외 발생으로 변경
        //            }
        //            return User(from: userDTO)
        //        }
        //        
        //        return users
        return []
    }
    
    // 사용자 정보를 Firestore에서 가져오는 메서드
    func fetchUser(by userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        guard let user = try document.data(as: User?.self) else {
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
    
    func connectUser(of userA: User, with userB: User) async throws {
        //        guard let userAId = userA.id, let userBId = userB.id else {
        //            throw FirestoreServiceError.invalidUserId
        //        }
        //        
        //        // Fetch the connection document for userA
        //        let userADoc = try await db.collection("connections").document(userAId).getDocument()
        //        if var connectionA = try? userADoc.data(as: ConnectionDTO.self) {
        //            // If the connection document exists, update the connectedTo array
        //            if !connectionA.connectedTo.contains(userBId) {
        //                connectionA.connectedTo.append(userBId)
        //                try db.collection("connections").document(userAId).setData(from: connectionA)
        //            }
        //        } else {
        //            // If the connection document does not exist, create a new one
        //            let connectionA = ConnectionDTO(id: userAId, connectedTo: [userBId])
        //            try db.collection("connections").document(userAId).setData(from: connectionA)
        //        }
        //        
        //        // Fetch the connection document for userB
        //        let userBDoc = try await db.collection("connections").document(userBId).getDocument()
        //        if var connectionB = try? userBDoc.data(as: ConnectionDTO.self) {
        //            // If the connection document exists, update the connectedTo array
        //            if !connectionB.connectedTo.contains(userAId) {
        //                connectionB.connectedTo.append(userAId)
        //                try db.collection("connections").document(userBId).setData(from: connectionB)
        //            }
        //        } else {
        //            // If the connection document does not exist, create a new one
        //            let connectionB = ConnectionDTO(id: userBId, connectedTo: [userAId])
        //            try db.collection("connections").document(userBId).setData(from: connectionB)
        //        }
    }
    ///
    func fetchConnectionStatus(user: User) async throws -> ConnectionRequestStatus {
//        guard let userId = user.id else {
//            throw FirestoreServiceError.invalidUserId
//        }
//        
//        let doc = try await db.collection("connections").document(userId).getDocument()
//        guard let connection = try? doc.data(as: ConnectionDTO.self) else {
//            throw FirestoreServiceError.documentNotFound
//        }
//        
//        if connection.connectedTo.isEmpty {
//            return .rejected
//        } else {
//            return .accepted
//        }
        return .accepted
    }
    
    
    /// 연결 요청을 Firestore에 업로드하는 메서드
    func uploadConnectionRequest(from: String, to: String) async throws {
        let request = ConnectionRequestsDTO(
            id: nil,
            from: from,
            to: to,
            status: .pending,
            requestDate: Date()
        )
        try db.collection("connectionRequests").addDocument(from: request)
    }
    
    /// 특정 사용자의 연결 요청을 Firestore에서 가져오는 메서드
    func fetchConnectionRequests(for userId: String) async throws -> [ConnectionRequestsDTO] {
        print("to 에서" + userId + " 찾는중")
        let snapshot = try await db.collection("connectionRequests")
            .whereField("to", isEqualTo: userId)
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
        
        try await db.collection("users").document(userId).setData(from: user, merge: true)
    }
}
