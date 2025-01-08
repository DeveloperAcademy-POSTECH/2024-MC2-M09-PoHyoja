//
//  MockLocalStorageService.swift
//  PicCharge
//
//  Created by 남유성 on 12/30/24.
//

import Foundation

class MockLocalStorageServiceImpl: LocalStorageService {
    func fetchUser() async -> User? {
        return User(name: "Mock", role: .child, email: "Mock@Mock.com", connectedTo: [])
    }
    
    func addUser(_ user: User) async throws {
        print("Mock 로컬 유저 추가됨")
    }
    
    func deleteUser(_ name: String) async throws {
        print("Mock 로컬 유저 삭제됨")
    }
    
    func fetchPhotos(for option: PhotoSortOption, _ order: SortOrder) async -> [Photo] {
        []
    }
    
    func fetchPhotos() async -> [Photo] {
        return [
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: []),
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: []),
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: [])
        ]
    }
    
    func fetchPhotos(for option: PhotoSortOption, _ order: SortOrder) async -> [Photo] {
        return [
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: []),
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: []),
            .init(id: UUID(), uploadBy: "Mock", uploadDate: .now, likeCount: 0, sharedWith: [])
        ]
    }
    
    func addPhoto(_ photo: Photo) async throws {
        print("Mock 로컬 사진 추가됨")
    }
    
    func deletePhoto(_ photoId: UUID) async throws {
        print("Mock 로컬 사진 삭제됨")
    }
    
    
}
