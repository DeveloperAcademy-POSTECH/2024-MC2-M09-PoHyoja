//
//  MockRemoteStorageServiceImpl.swift
//  PicCharge
//
//  Created by 남유성 on 12/30/24.
//

import Foundation

class MockRemoteStorageServiceImpl: RemoteStorageService {
    func fetchUserByEmail(_ email: String) async throws -> User? {
        return User(name: "Mock", role: .child, email: "Mock@Mock.com", connectedTo: [])
    }
    
    func fetchUserByName(_ name: String) async throws -> User? {
        return User(name: "Mock", role: .child, email: "Mock@Mock.com", connectedTo: [])
    }
    
    func checkUserExists(by name: String) async throws -> Bool {
        return true
    }
    
    func addUser(_ user: User) async throws {
        print("Mock 원격 유저 추가됨")
    }
    
    func deleteUser(_ user: User) async throws {
        print("Mock 원격 유저 삭제됨")
    }
    
    func fetchPhotos(_ userName: String) async throws -> [Photo] {
        return [
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: []),
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: []),
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: [])
        ]
    }
    
    func addPhoto(_ photo: Photo, urlString: String) async throws {
        print("Mock 원격 사진 추가됨")
    }
    
    func uploadPhotoData(of userName: String, photo: Photo, imgData: Data) async throws -> String {
        print("Mock 원격 사진 업로드됨")
        return "MockUrlString"
    }
    
    func downloadPhotoData(of urlString: String) async throws -> Data {
        return Data()
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        print("Mock 원격 사진 업데이트 됨")
    }
    
    func deletePhoto(of photoId: UUID) async throws {
        print("Mock 원격 사진 삭제 됨")
    }
}
