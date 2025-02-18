//
//  MockLocalRepository.swift
//  PicCharge
//
//  Created by 남유성 on 1/31/25.
//

import Foundation

final class MockLocalRepository: LocalRepository {
    
    private var currentUser: User?
    private var photos: [Photo]
    
    init(user: User? = nil, photos: [Photo] = []) {
        self.currentUser = user
        self.photos = photos
    }
    
    func fetchUser() async -> User? {
        return currentUser
    }
    
    func addUser(_ user: User) async throws {
        currentUser = user
    }
    
    func addConnection(of user: User, with connectedTo: [String]) async throws {
        guard currentUser?.name == user.name else { return }
        currentUser?.connectedTo = connectedTo
    }
    
    func deleteUser(_ name: String) async throws {
        if currentUser?.name == name {
            currentUser = nil
        }
    }
    
    func fetchPhotos() async -> [Photo] {
        return photos
    }
    
    func fetchPhotos(for option: PhotoSortOption, _ order: SortOrder) async -> [Photo] {
        return photos.sorted {
            order == .forward ? $0.uploadDate < $1.uploadDate : $0.uploadDate > $1.uploadDate
        }
    }
    
    func addPhoto(_ photo: Photo) async throws {
        photos.append(photo)
    }
    
    func addPhotos(_ photos: [Photo]) async throws {
        self.photos.append(contentsOf: photos)
    }
    
    func updatePhotos(_ photos: [Photo]) async throws {
        for photo in photos {
            if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                self.photos[index] = photo
            }
        }
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index] = photo
        }
    }
    
    func deletePhoto(_ photoId: UUID) async throws {
        photos.removeAll { $0.id == photoId }
    }
    
    func deletePhotos(_ photoIds: [UUID]) async throws {
        photos.removeAll { photoIds.contains($0.id) }
    }
    
    func deleteAllPhotos() async throws {
        photos.removeAll()
    }
}
