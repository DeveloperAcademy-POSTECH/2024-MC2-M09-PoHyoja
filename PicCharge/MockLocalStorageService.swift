//
//  MockLocalStorageService.swift
//  PicCharge
//
//  Created by 남유성 on 12/30/24.
//

import Foundation

class MockLocalStorageServiceImpl: LocalStorageService {
    func fetchUser() async -> User? {
        return nil
    }
    
    func addUser(_ user: User) async throws {
        print("add User")
    }
    
    func deleteUser(_ name: String) async throws {
        print("delete User")
    }
    
    func fetchPhotos() async -> [Photo] {
        return []
    }
    
    func addPhoto(_ photo: Photo) async throws {
        print("add Photo")
    }
    
    func deletePhoto(_ photoId: UUID) async throws {
        print("delete Photo")
    }
}
