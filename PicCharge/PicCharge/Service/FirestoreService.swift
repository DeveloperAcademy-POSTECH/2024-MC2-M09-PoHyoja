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
    
    private let db = Firestore.firestore()
    
    func fetchPhotos(user: User) async throws -> [Photo]? {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        
        let snapShot: QuerySnapshot
        
        switch user.role {
        case Role.child:
            snapShot = try await db.collection("photos").whereField("uploadBy", isEqualTo: userId).getDocuments()
            
        case Role.parent:
            snapShot = try await db.collection("photos").whereField("sharedWith", arrayContains: userId).getDocuments()
        }
        
        return try filterPhotos(by: snapShot, userId: userId)
    }

    private func filterPhotos(by snapShot: QuerySnapshot, userId: String) throws -> [Photo]? {
        if snapShot.isEmpty {
            return nil
        }
        
        var photoDTOs: [PhotoDTO] = []
        var seenIds = Set<String>()
        
        let photos = snapShot.documents.compactMap { document -> (PhotoDTO)? in
            guard let photoDTO = try? document.data(as: PhotoDTO.self), let id = photoDTO.id else {
                return nil
            }
            
            if !seenIds.contains(id) {
                seenIds.insert(id)
                photoDTOs.append(photoDTO)
            }
        }
        
        return try photoDTOs.compactMap { dto -> Photo in
            do {
                return try Photo(from: dto)
            } catch FirestoreServiceError.invalidUUID {} // 오류 발생 시 사진 추가 안함
        }
    }
    
    // TODO: Photo 대신에 Image 를 받는 등 로직 개선 필요함
    // TODO: Firebase Storage 연결
    func addPhoto(child: Child, parent: Parent, imageData: Data) async throws {
//        guard let childID = child.id, let parentID = parent.id else {
//            throw FirestoreServiceError.invalidUserId
//        }
//        let photoDTO = PhotoDTO(photo: imageData, sharedWith: [parentID])
//        try db.collection("photos").addDocument(from: photoDTO)
    }
    
    private func validatePhoto(child: Child, parent: Parent, photo: Photo) -> Bool {
        if photo.uploadBy != child.id {
            return false// TODO: 예외 처리로 로직 변경
        }
    }
    
    func updatePhotoLikeCount(user: Parent, of photo: Photo, by plusLikeCount: Int) async throws {
        let photoSnapshot = try await db.collection("photos").document(photo.id.uuidString).getDocument()
        guard let photoData = photoSnapshot.data() else {
            throw FirestoreServiceError.documentNotFound
        }
        
        guard let photo = try? photoSnapshot.data(as: PhotoDTO.self) else {
            return // TODO: 예외 발생으로 변경
            //throw FirestoreServiceError.decodingError
        }
        
    }
    
    func deletePhoto(photo: Photo) async throws {
        let photoId = photo.id
//        try await db.collection("photos").document(photoId.uuidString).delete()
        // TODO: 사진이 공유된 사람들만 삭제 가능
    }
    
    func fetchSerchedUsers(searchUserId: String) async throws -> [User] {
        let document = try await db.collection("users")
            .whereField("role", isEqualTo: Role.child.rawValue) // TODO: Rold.child 대신 유저의 역할 가져와서 반대 역할 검색해야 함
            .start(at: [searchUserId])
            .end(at: [searchUserId + "\u{f8ff}"])
            .getDocuments()
        
        guard !document.isEmpty else {
            throw FirestoreServiceError.userNotFound
        }
        
        let users = document.documents.compactMap { document -> (any User)? in
            guard let userDTO = try? document.data(as: UserDTO.self) else {
                return nil // TODO: 예외 발생으로 변경
            }
            switch userDTO.role {
            case .parent:
                return Parent(from: userDTO)
            case .child:
                return Child(from: userDTO)
            case .none:
                return nil
            }
        }
        
        return users
    }
    
    
    func addUser(user: any User) async throws {
        let userDTO = UserDTO(user: user)
        try db.collection("users").addDocument(from: userDTO)
    }
    
   
    func deleteUser(user: any User) async throws {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        try await db.collection("users").document(userId).delete()
    }
    
    func connectUser(of userA: any User, with userB: any User) async throws {
        <#code#>
    }
    
    func fetchConnectionStatus(user: User) async throws -> ConnectionRequestStatus {
        guard let userId = user.id else {
            throw FirestoreServiceError.invalidUserId
        }
        
        let doc = try await db.collection("connections").document(userId).getDocument()
        guard let connection = try? doc.data(as: ConnectionDTO.self) else {
            throw FirestoreServiceError.documentNotFound
        }
        
        if connection.connectedTo.isEmpty {
            return .rejected
        } else {
            return .accepted
        }
    }
}
