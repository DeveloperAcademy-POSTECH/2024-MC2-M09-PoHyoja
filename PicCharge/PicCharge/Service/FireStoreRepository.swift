//
//  FireStoreRepository.swift
//  PicCharge
//
//  Created by 남유성 on 1/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class FireStoreRepository: RemoteStorageService {
    
    typealias ServiceError = FireStoreError
    
    private let db: Firestore
    private let storage: Storage
    
    init(fireStore: Firestore, storage: Storage) {
        self.db = fireStore
        self.storage = storage
    }
    
    var userCollection: String { "users" }
    var photoCollection: String { "photos" }
    var folder: String { "photos" }
}

extension FireStoreRepository {
    func fetchUserByEmail(_ email: String) async throws -> User? {
        
        // 1. FireStore 이메일 일치 여부 세팅
        let document = db.collection(userCollection)
            .whereField("email", isEqualTo: email)
        
        // 2. 유저 데이터 가져오기
        guard let snapshot = try? await document.getDocuments().documents else {
            throw ServiceError.invalidQuery
        }
        
        // 3. 데이터에서 유저 정보 변환 [유저정보] -> 유저정보
        guard let user = snapshot.first else { return nil }
        
        do {
            // 4. DTO -> Domain
            return try user.data(as: UserDTO.self).toDomain()
            
        } catch {
            throw ServiceError.invalidUserDTOFormat
        }
    }
    
    func fetchUserByName(_ name: String) async throws -> User? {
        
        // 1. 유저 이름 체크
        guard !name.isEmpty else { throw ServiceError.invalidUserName }
        
        // 2. FireStore 이름 일치 여부 세팅
        let document = db.collection(userCollection)
            .whereField("name", isEqualTo: name)
        
        // 3. 유저 데이터 가져오기
        guard let snapshot = try? await document.getDocuments().documents else {
            throw ServiceError.invalidQuery
        }
        
        // 4. 데이터에서 유저 정보 변환 [유저정보] -> 유저정보
        guard let user = snapshot.first else { return nil }
        
        do {
            // 5. DTO -> Domain
            return try user.data(as: UserDTO.self).toDomain()
            
        } catch {
            throw ServiceError.invalidUserDTOFormat
        }
    }
    
    func checkUserExists(by name: String) async throws -> Bool {
        // 1. 유저 이름 체크
        guard !name.isEmpty else { throw ServiceError.invalidUserName }
        
        // 2. 이름 일치 여부 세팅
        let snapshot = db.collection(userCollection)
            .whereField("name", isEqualTo: name)
            
        do {
            // 3. 쿼리 데이터 호출
            let documents = try await snapshot.getDocuments().documents
            
            return !documents.isEmpty
        } catch {
            throw ServiceError.invalidQuery
        }
    }
    
    func addUser(_ user: User) async throws {
        
        // 1. 기존 유저 여부 체크
        let userExists = try await checkUserExists(by: user.name)
        
        guard !userExists else {
            throw ServiceError.userAlreadyExists
        }
        
        // 2. 신규 DTO 생성
        let userDTO = UserDTO(domain: user)

        // 3. Id 가능여부 확인
        guard let userId = userDTO.id else {
            throw ServiceError.invalidUserId
        }
        
        do {
            // 4. 유저 데이터 저장
            try db.collection(userCollection)
                .document(userId)
                .setData(from: userDTO)
            
        } catch {
            throw ServiceError.addUserFailed(error: error.localizedDescription)
        }
    }
    
    func deleteUser(_ user: User) async throws {
        
        // 1. FireStore 이메일 일치 여부 세팅
        let document = db.collection(userCollection)
            .whereField("email", isEqualTo: user.email)
        
        // 2. 유저 데이터 가져오기
        guard let snapshot = try? await document.getDocuments().documents else {
            throw ServiceError.invalidQuery
        }
        
        // 3. 데이터에서 유저 정보 변환 [유저정보] -> 유저정보
        guard let user = snapshot.first else {
            throw ServiceError.userNotExists
        }
        
        // 4. 유저 Id 확인
        guard let userId = try? user.data(as: UserDTO.self).id else {
            throw ServiceError.invalidUserDTOFormat
        }
       
        do {
            // 5. 유저 삭제
            try await db.collection(userCollection)
                .document(userId)
                .delete()
            
        } catch {
            throw ServiceError.deleteUserFailed(error: error.localizedDescription)
        }
    }
}

extension FireStoreRepository {
    private func migrationPhoto(_ userName: String) async throws {
        
        let document = db.collection(photoCollection)
            .whereField("sharedWith", arrayContains: userName)
        
        guard let documents = try? await document.getDocuments().documents else {
            throw ServiceError.invalidQuery
        }
        
        let group = DispatchGroup()
        
        for document in documents {
            guard let photoV0 = try? document.data(as: PhotoDTO_V0.self) else { continue }
            
            let migratedPhoto = photoV0.toV1()
            
            group.enter()
            try document.reference.setData(from: migratedPhoto) { _ in
                group.leave()
            }
        }
        
        group.wait()
    }
    
    func fetchPhotos(_ userName: String) async throws -> [Photo] {
        do {
            return try await _fetchPhotos(userName)
            
        } catch ServiceError.invalidPhotoDTOFormat {
        
            try await migrationPhoto(userName)
            
            return try await _fetchPhotos(userName)
            
        }
    }
    
    private func _fetchPhotos(_ userName: String) async throws -> [Photo] {
        
        // 1. 유저 네임 check
        guard !userName.isEmpty else { throw ServiceError.invalidUserName }
        
        let document = db.collection(photoCollection)
            .whereField("sharedWith", arrayContains: userName)
        
        // 2. FireStore에서 자료 가져오기
        guard let documents = try? await document.getDocuments().documents else {
            throw ServiceError.invalidQuery
        }
        
        // 3. DTO -> Domain으로 변환
        do {
            return try documents
                .map { try $0.data(as: PhotoDTO_V1.self) }
                .map { $0.toDomain() }
            
        } catch {
            throw ServiceError.invalidPhotoDTOFormat
        }
    }
    
    func addPhoto(_ photo: Photo, urlString: String) async throws {
        let photoDTO = PhotoDTO_V1(photo, urlString: urlString)
        
        do {
            // 1. DB 사진 URL 정보 업데이트
            try db.collection(photoCollection)
                .document(photo.id.uuidString)
                .setData(from: photoDTO)
                
        } catch {
            throw ServiceError.updatePhotoFailed(error: error.localizedDescription)
        }
    }
    
    func uploadPhotoData(of userName: String, photo: Photo) async throws -> String {

        guard let imgData = photo.imgData else { throw ServiceError.noPhotoData }
        
        // 1. 업로드 위치 결정
        let storageRef = storage.reference().child("\(folder)/\(userName)/\(photo.id.uuidString).jpg")
        
        // 2. 업로드
        do {
            _ = try await storageRef.putDataAsync(imgData, metadata: nil)
        } catch {
            throw ServiceError.uploadPhotoFailed(error: error.localizedDescription)
        }
        
        // 3. 다운로드 URL 변환 (업로드 후 접근 가능)
        do {
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL.absoluteString
            
        } catch {
            throw ServiceError.updatePhotoFailed(error: error.localizedDescription)
        }
    }
    
    func downloadPhotoData(of urlString: String) async throws -> Data {
        do {
            // 1. Storage 주소
            let storageRef = storage.reference(forURL: urlString)
            
            // 2. 다운로드
            return try await storageRef.data(maxSize: 5 * 1024 * 1024)
        } catch {
            throw ServiceError.downloadPhotoFailed(error: error.localizedDescription)
        }
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        do {
            // TODO: - 카운드 업데이트 메커니즘 변경
            try await db.collection(photoCollection)
                .document(photo.id.uuidString)
                .updateData([
                    "reactions" : [
                        "love" : photo.reaction.love,
                        "fire" : photo.reaction.fire,
                        "star" : photo.reaction.star,
                        "like" : photo.reaction.like
                    ]
                ])
        } catch {
            throw ServiceError.updatePhotoFailed(error: error.localizedDescription)
        }
    }
    
    func deletePhotoData(of urlString: String) async throws {
        let storageRef = storage.reference(forURL: urlString)
        
        try await storageRef.delete()
    }
    
    func deletePhoto(of photoId: UUID) async throws {
        
        // 1. FireStore 사진 주소 변환
        let photoRef = db.collection(photoCollection)
            .document(photoId.uuidString)
        
        // 2. 사진 데이터 가져오기
        guard let snapshot = try? await photoRef.getDocument() else {
            throw ServiceError.invalidQuery
        }
        
        // 3. DTO로 변환
        guard let photoDTO = try? snapshot.data(as: PhotoDTO_V1.self) else {
            throw ServiceError.invalidPhotoDTOFormat
        }
        
        // 4. Storage 사진 주소 변환
        let storageRef = storage.reference(forURL: photoDTO.urlString)
        
        // 5. 사진 삭제 병렬 처리
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                // 5-1. Storage에서 삭제
                group.addTask {
                    try await storageRef.delete()
                }
                
                // 5-2. Firestore에서 문서 삭제
                group.addTask {
                    try await photoRef.delete()
                }
                
                // 모든 작업 완료 대기
                try await group.waitForAll()
            }
        } catch {
            throw ServiceError.deletePhotoFailed(error: error.localizedDescription)
        }
    }
}
