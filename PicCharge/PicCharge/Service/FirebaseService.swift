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
    
    var userCollection: String { isTest ? "testUser" : "user" }
    var photoCollection: String { isTest ? "testPhoto" : "photo" }
    
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
    func fetchPhotos(_ userName: String) async -> [Photo] {
        return []
    }
    
    func uploadPhoto(of userName: String, photo: Photo) async throws {
        
    }
    
    func downloadPhoto(of urlString: String) async throws -> Data {
        return Data()
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        
    }
    
    func deletePhoto(of photoId: String) async throws {
        
    }
}
