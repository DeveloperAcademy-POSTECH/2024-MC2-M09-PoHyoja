//
//  DefaultLocalRepository.swift
//  PicCharge
//
//  Created by 남유성 on 12/31/24.
//

import Foundation
import SwiftData

final class DefaultLocalRepository: LocalRepository {

    private let userDataSource: EntityDataSource<UserEntity>
    private let photoDataSource: EntityDataSource<PhotoEntity>

    init(isMemoryOnly: Bool = false) {
        let persistanceStack = PersistenceStack(isMemoryOnly: isMemoryOnly)
        
        self.userDataSource = EntityDataSource<UserEntity>(modelContainer: persistanceStack.container)
        self.photoDataSource = EntityDataSource<PhotoEntity>(modelContainer: persistanceStack.container)
    }
}

// MARK: - User Entity
extension DefaultLocalRepository {
    func fetchUser() async -> User? {
        do {
            let userEntity: [UserEntity] = try await userDataSource.fetch()
            
            return userEntity.first?.toDomain()
        } catch {
            return nil
        }
    }
    
    func addUser(_ user: User) async throws {
        let userEntity = UserEntity(user)
        
        try await userDataSource.perform(.create([userEntity]))
    }
    
    func addConnection(of user: User, with connectedTo: [String]) async throws {
        let userEntity = UserEntity(user)
        userEntity.connectedTo += connectedTo
        
        try await userDataSource.perform(.update([userEntity]))
    }
    
    func deleteUser(_ name: String) async throws {
        try await userDataSource.perform(.delete(#Predicate { $0.name == name }))
    }
}

// MARK: - Photo Entity
extension DefaultLocalRepository {
    func fetchPhotos() async -> [Photo] {
        await fetchPhotos(for: .uploadDate, .reverse)
    }
    
    func fetchPhotos(for option: PhotoSortOption, _ order: SortOrder) async -> [Photo] {
        do {
            let photoEntities: [PhotoEntity] = try await photoDataSource.fetch(
                sortDescriptors: PhotoSortDescriptor.build(option, order: order)
            )
            
            return photoEntities.map { $0.toDomain() }
        } catch {
            return []
        }
    }
    
    func addPhoto(_ photo: Photo) async throws {
        let photoEntity = PhotoEntity(photo)
        
        try await photoDataSource.perform(.create([photoEntity]))
    }
    
    func addPhotos(_ photos: [Photo]) async throws {
        let photoEntitys = photos.map { PhotoEntity($0) }
        
        try await photoDataSource.perform(.create(photoEntitys))
    }
    
    func updatePhotos(_ photos: [Photo]) async throws {
        let photoEntitys = photos.map { PhotoEntity($0) }
        
        try await photoDataSource.perform(.update(photoEntitys))
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        try await photoDataSource.perform(.update([PhotoEntity(photo)]))
    }
    
    func deletePhoto(_ photoId: UUID) async throws {
        try await photoDataSource.perform(.delete(#Predicate { $0.id == photoId }))
    }
    
    func deletePhotos(_ photoIds: [UUID]) async throws {
        let photoSet = Set(photoIds)
        
        try await photoDataSource.perform(.delete(#Predicate { photoSet.contains($0.id) }))
    }
    
    func deleteAllPhotos() async throws {
        try await photoDataSource.perform(.deleteAll)
    }
    
    func syncChanges(toUpdate: [Photo],
                     toAdd: [Photo],
                     toDelete: [UUID]) async throws {
        
        let toAddEntity = toAdd.map { PhotoEntity($0) }
        let toUpdateEntity = toUpdate.map { PhotoEntity($0) }
        let toDeleteEntityIds = Set(toDelete)
        
        try await photoDataSource.perform(.create(toAddEntity),
                                          .update(toUpdateEntity),
                                          .delete(#Predicate { toDeleteEntityIds.contains($0.id) }))
    }
}

extension DefaultLocalRepository {
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
