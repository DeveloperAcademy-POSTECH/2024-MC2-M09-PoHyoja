//
//  MockRemoteStorageServiceImpl.swift
//  PicCharge
//
//  Created by 남유성 on 12/30/24.
//

import Foundation

class MockRemoteStorageServiceImpl: RemoteStorageService {
    func downloadPhoto(of urlString: String) async throws -> Data {
        return Data()
    }
    
    func fetchUserByEmail(_ email: String) async throws -> User? {
        return nil
    }
    
    func fetchUserByName(_ name: String) async throws -> User? {
        return nil
    }
    
    func checkUserExists(by name: String) async throws -> Bool {
        return false
    }
    
    func addUser(_ user: User) async throws {
        print("add User")
    }
    
    func deleteUser(_ user: User) async throws {
        print("delete User")
    }
    
    func fetchPhotos(_ userName: String) async -> [Photo] {
        return []
    }
    
    func uploadPhoto(of userName: String, photo: Photo) async throws {
        print("upload Photo")
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        print("update Photo")
    }
    
    func deletePhoto(of photoId: UUID) async throws {
        print("delete Photo")
    }
}
