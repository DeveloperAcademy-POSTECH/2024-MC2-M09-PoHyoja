//
//  FirebaseService.swift
//  PicCharge
//
//  Created by 남유성 on 1/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage



enum RemoteStorageServiceError: Error {
    case invalidUserName
    case invalidUserId
    case userAlreadyExists
    
    case invalidPhotoData
    case invalidDownloadURL
    case documentPhotoNotFound
    case uploadPhotoFailed
    case downloadPhotoFailed
    case updatePhotoFailed
    case invalidPhotoDTOFormat
    
    case missingImageData

    case deletePhotoFailed
    
}

extension RemoteStorageServiceError: LocalizedError {
    
}

class FirebaseService: RemoteStorageService {
    
    typealias ServiceError = RemoteStorageServiceError
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private let isTest: Bool
    
    init(isTest: Bool = false) {
        self.isTest = isTest
    }
    
    var userCollection: String { isTest ? "testUser" : "users" }
    var photoCollection: String { isTest ? "testPhotos" : "photos" }
    
    func clearTests() async throws {
        guard isTest else { return }
        
        _ = try await db.collection(userCollection)
            .getDocuments()
            .documents
            .map { document in
                Task {
                    try await document.reference.delete()
                }
            }
        
        _ = try await db.collection(photoCollection)
            .getDocuments()
            .documents
            .map { document in
                Task {
                    try await document.reference.delete()
                }
            }
    }
}

extension FirebaseService {
    func fetchUserByEmail(_ email: String) async -> User? {
        do {
            let snapshot = try await db.collection(userCollection)
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            guard let document = snapshot.documents.first else {
                return nil
            }
            
            return try document.data(as: UserDTO.self).toDomain()
            
        } catch {
            print(#fileID, #function, #line, "유저 Fetch Error: \(error)")
            return nil
        }
    }
    
    func fetchUserByName(_ name: String) async -> User? {
        do {
            let snapshot = try await db.collection(userCollection)
                .whereField("name", isEqualTo: name)
                .getDocuments()
            
            guard let document = snapshot.documents.first else {
                return nil
            }
            
            return try document.data(as: UserDTO.self).toDomain()
            
        } catch {
            print(#fileID, #function, #line, "유저 Fetch Error: \(error)")
            return nil
        }
    }
    
    func checkUserExists(by name: String) async throws -> Bool {
        guard !name.isEmpty
        else { throw ServiceError.invalidUserName }
        
        let querySnapshot = try await db.collection(userCollection)
            .whereField("name", isEqualTo: name)
            .getDocuments()
        
        return !querySnapshot.documents.isEmpty
    }
    
    func addUser(_ user: User) async throws {
        let userExists = try await checkUserExists(by: user.name)
        
        guard !userExists else { throw ServiceError.userAlreadyExists }
        
        let userDTO = UserDTO(domain: user)
        
        guard let userId = userDTO.id else { throw ServiceError.invalidUserId }
        
        do {
            try db.collection(userCollection)
                .document(userId)
                .setData(from: userDTO)
        } catch {
            print(#fileID, #function, #line, "서버 에러")
            throw error
        }
    }
    
    func deleteUser(_ user: User) async throws {
        let userDTO = UserDTO(domain: user)
        
        guard let userId = userDTO.id else { throw ServiceError.invalidUserId }
        
        do {
            try await db.collection(userCollection)
                .document(userId)
                .delete()
        } catch {
            print(#fileID, #function, #line, "서버 에러")
            throw error
        }
    }
}

extension FirebaseService {
    func fetchPhotos(_ userName: String) async throws -> [Photo] {
        
        // 1. 유저 네임 check
        guard !userName.isEmpty else { throw ServiceError.invalidUserName }
        
        let document = db.collection(photoCollection)
            .whereField("sharedWith", arrayContains: userName)
        
        // 2. FireStore에서 자료 가져오기
        guard let snapshots = try? await document.getDocuments().documents else {
            throw ServiceError.documentPhotoNotFound
        }
        
        // 3. DTO -> Domain으로 변환
        return snapshots
            .compactMap { try? $0.data(as: PhotoDTO.self) }
            .map { $0.toDomain() }
    }
    
    func uploadPhoto(of userName: String, photo: Photo) async throws {
        
        // 1. 이미지 데이터 확인
        guard let imgData = photo.imgData else {
            throw ServiceError.invalidPhotoData
        }

        // 2. 업로드 위치 결정
        let storageRef = storage.reference().child("photos/\(userName)/\(photo.id.uuidString).jpg")
        
        // 3. 업로드
        guard let _ = try? await storageRef.putDataAsync(imgData, metadata: nil) else {
            throw ServiceError.uploadPhotoFailed
        }
        
        // 4. 다운로드 URL 변환 (업로드 후 접근 가능)
        guard let downloadURL = try? await storageRef.downloadURL() else {
            throw ServiceError.downloadPhotoFailed
        }
        
        do {
            // 5. DB 사진 URL 정보 업데이트
            try await db.collection(photoCollection)
                .document(photo.id.uuidString)
                .updateData([
                    "urlString" : downloadURL.absoluteString
                ])
        } catch {
            throw ServiceError.updatePhotoFailed
        }
    }
    
    func downloadPhoto(of urlString: String) async throws -> Data {
        do {
            // 1. Storage 주소
            let storageRef = storage.reference(forURL: urlString)
            
            // 2. 다운로드
            return try await storageRef.data(maxSize: 5 * 1024 * 1024)
        } catch {
            throw ServiceError.downloadPhotoFailed
        }
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        do {
            // TODO: - 카운드 업데이트 메커니즘 변경
            try await db.collection(photoCollection)
                .document(photo.id.uuidString)
                .updateData([
                    "likeCount" : photo.likeCount
                ])
            
        } catch {
            throw ServiceError.updatePhotoFailed
        }
    }
    
    func deletePhoto(of photoId: UUID) async throws {
        
        // 1. FireStore 사진 주소 변환
        let photoRef = db.collection(photoCollection)
            .document(photoId.uuidString)
        
        // 2. 사진 데이터 가져오기
        guard let snapshot = try? await photoRef.getDocument() else {
            throw ServiceError.documentPhotoNotFound
        }
        
        // 3. DTO로 변환
        guard let photoDTO = try? snapshot.data(as: PhotoDTO.self) else {
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
            throw ServiceError.deletePhotoFailed
        }
    }
}
