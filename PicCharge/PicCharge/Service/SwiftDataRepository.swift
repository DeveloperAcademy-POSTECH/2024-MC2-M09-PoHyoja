//
//  SwiftDataRepository.swift
//  PicCharge
//
//  Created by 남유성 on 12/31/24.
//

import Foundation
import SwiftData

final class SwiftDataRepository: LocalStorageService {
    
    private let userStorage: SwiftDataService<UserEntity>
    private let photoStorage: SwiftDataService<PhotoEntity>

    init(isMemoryOnly: Bool = false) {
        let persistanceStack = PersistenceStack(isMemoryOnly: isMemoryOnly)
        
        self.userStorage = SwiftDataService<UserEntity>(container: persistanceStack.container)
        self.photoStorage = SwiftDataService<PhotoEntity>(container: persistanceStack.container)
    }
}

// MARK: - User Entity
extension SwiftDataRepository {
    func fetchUser() async -> User? {
        do {
            let userEntity: [UserEntity] = try userStorage.read()
            
            return userEntity.first?.toDomain()
        } catch {
            return nil
        }
    }
    
    func addUser(_ user: User) async throws {
        let userEntity = UserEntity(user)
        
        try userStorage.create(userEntity)
    }
    
    func addConnection(of user: User, with connectedTo: [String]) async throws {
        let userEntity = UserEntity(user)
        userEntity.connectedTo += connectedTo
        try userStorage.update(userEntity)
    }
    
    func deleteUser(_ name: String) async throws {
        try userStorage.delete(where: #Predicate { $0.name == name })
    }
}

// MARK: - Photo Entity
extension SwiftDataRepository {
    func fetchPhotos() async -> [Photo] {
        await fetchPhotos(for: .uploadDate, .reverse)
    }
    
    func fetchPhotos(for option: PhotoSortOption, _ order: SortOrder) async -> [Photo] {
        do {
            let photoEntities: [PhotoEntity] = try photoStorage.read(
                sortDescriptors: PhotoSortDescriptor.build(option, order: order)
            )
            
            return photoEntities.map { $0.toDomain() }
        } catch {
            return []
        }
    }
    
    func addPhoto(_ photo: Photo) async throws {
        let photoEntity = PhotoEntity(photo)
        
        try photoStorage.create(photoEntity)
    }
    
    func addPhotos(_ photos: [Photo]) async throws {
        try photoStorage.create(photos.map { PhotoEntity($0) })
    }
    
    func updatePhotos(_ photos: [Photo]) async throws {
        try photoStorage.update(photos.map { PhotoEntity($0) })
    }
    
    func deletePhoto(_ photoId: UUID) async throws {
        try photoStorage.delete(where: #Predicate { $0.id == photoId })
    }
    
    func deletePhotos(_ photoIds: [UUID]) async throws {
        let photoSet = Set(photoIds)
        
        try photoStorage.delete(where: #Predicate { item in
            photoSet.contains(item.id)
        })
    }
    
    func deleteAllPhotos() async throws {
        try photoStorage.deleteAll()
    }
}

extension SwiftDataRepository {
    struct PhotoSortDescriptor {
        static func build(_ option: PhotoSortOption = .uploadDate,
                          order: SortOrder = .reverse) -> SortDescriptor<PhotoEntity> {
            
            switch option {
            case .uploadDate:
                return SortDescriptor(\.uploadDate, order: order)
            }
        }
    }
}
