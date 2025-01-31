//
//  MockRemoteRepository.swift
//  PicCharge
//
//  Created by 남유성 on 1/31/25.
//

import UIKit

enum MockResponseType {
    case success
    case error
}

final class MockRemoteRepository: RemoteRepository {
    
    private var users: [User]
    private var photos: [Photo]
    private var response: MockResponseType
    
    init(users: [User] = [],
         photos: [Photo] = [],
         response: MockResponseType) {
        self.users = users
        self.photos = photos
        self.response = response
    }
    
    func fetchUserByEmail(_ email: String) async throws -> User? {
        switch response {
        case .success:
            return users.first { $0.email == email }
            
        case .error:
            throw FireStoreError.userNotExists
        }
    }
    
    func fetchUserByName(_ name: String) async throws -> User? {
        switch response {
        case .success:
            return users.first { $0.name == name }
            
        case .error:
            throw FireStoreError.userNotExists
        }
    }
    
    func checkUserExists(by name: String) async throws -> Bool {
        switch response {
        case .success:
            return users.contains { $0.name == name }
        
        case .error:
            throw FireStoreError.userNotExists
        }
    }
    
    func addUser(_ user: User) async throws {
        switch response {
        case .success:
            users.append(user)
        case .error:
            throw FireStoreError.addUserFailed(error: "Failed To add Mock User")
        }
    }
    
    func updateConnections(of userName: User, with connectedTo: [String]) async throws {
        switch response {
        case .success:
            if let index = users.firstIndex(where: { $0.name == userName.name }) {
                users[index].connectedTo = connectedTo
            }
            
        case .error:
            throw FireStoreError.updateUserFailed(error: "Failed To update Mock Connections")
        }
    }
    
    func deleteUser(_ user: User) async throws {
        switch response {
        case .success:
            users.removeAll { $0.name == user.name }
        
        case .error:
            throw FireStoreError.deleteUserFailed(error: "Failed to delete Mock user")
        }
    }
    
    func fetchLatestPhoto(_ userName: String) async -> Photo? {
        switch response {
        case .success:
            return photos
                .filter { $0.sharedWith.contains(userName) }
                .sorted(by: { $0.uploadDate > $1.uploadDate })
                .first
        
        case .error:
            return nil
        }
    }
    
    func fetchPhotos(_ userName: String) async throws -> [Photo] {
        switch response {
        case .success:
            return photos.filter { $0.sharedWith.contains(userName) }
        
        case .error:
            throw FireStoreError.noPhotoData
        }
    }
    
    func addPhoto(_ photo: Photo, urlString: String) async throws {
        switch response {
        case .success:
            let newPhoto = photo
            newPhoto.urlString = urlString
            photos.append(newPhoto)
            
        case .error:
            throw FireStoreError.addUserFailed(error: "Failed to add Mock Photo")
        }
    }
    
    func uploadPhotoData(of userName: String, photo: Photo) async throws -> String {
        switch response {
        case .success:
            return "https://mockstorage.com/\(photo.id.uuidString)"
            
        case .error:
            throw FireStoreError.uploadPhotoFailed(error: "Failed to upload Mock Photo")
        }
    }
    
    func downloadPhotoData(of urlString: String) async throws -> Data {
        switch response {
        case .success:
            return UIImage(resource: .child).pngData()!
            
        case .error:
            throw FireStoreError.downloadPhotoFailed(error: "Failed to download Mock Photo Data")
        }
    }
    
    func deletePhotoData(of urlString: String) async throws {
        switch response {
        case .success:
            photos.removeAll { $0.urlString == urlString }
            
        case .error:
            throw FireStoreError.deletePhotoFailed(error: "Failed to delete Mock Photo data")
        }
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        switch response {
        case .success:
            if let index = photos.firstIndex(where: { $0.id == photo.id }) {
                photos[index] = photo
            }
            
        case .error:
            throw FireStoreError.updatePhotoFailed(error: "Failed to update Mock Photo")
        }
    }
    
    func deletePhoto(of photoId: UUID) async throws {
        switch response {
        case .success:
            photos.removeAll { $0.id == photoId }
            
        case .error:
            throw FireStoreError.deletePhotoFailed(error: "Failed to delete Mock Photo")
        }
    }
}
