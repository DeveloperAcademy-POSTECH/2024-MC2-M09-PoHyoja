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
        
        self.userDataSource = EntityDataSource<UserEntity>(container: persistanceStack.container)
        self.photoDataSource = EntityDataSource<PhotoEntity>(container: persistanceStack.container)
    }
}

// MARK: - User Entity
extension DefaultLocalRepository {
    func fetchUser() async -> User? {
        do {
            let userEntity: [UserEntity] = try userDataSource.read()
            
            return userEntity.first?.toDomain()
        } catch {
            return nil
        }
    }
    
    func addUser(_ user: User) async throws {
        let userEntity = UserEntity(user)
        
        try userDataSource.create(userEntity)
    }
    
    func addConnection(of user: User, with connectedTo: [String]) async throws {
        let userEntity = UserEntity(user)
        userEntity.connectedTo += connectedTo
        try userDataSource.update(userEntity)
    }
    
    func deleteUser(_ name: String) async throws {
        try userDataSource.delete(where: #Predicate { $0.name == name })
    }
}

// MARK: - Photo Entity
extension DefaultLocalRepository {
    func fetchPhotos() async -> [Photo] {
        await fetchPhotos(for: .uploadDate, .reverse)
    }
    
    func fetchPhotos(for option: PhotoSortOption, _ order: SortOrder) async -> [Photo] {
        do {
            let photoEntities: [PhotoEntity] = try photoDataSource.read(
                sortDescriptors: PhotoSortDescriptor.build(option, order: order)
            )
            
            return photoEntities.map { $0.toDomain() }
        } catch {
            return []
        }
    }
    
    func addPhoto(_ photo: Photo) async throws {
        let photoEntity = PhotoEntity(photo)
        
        try photoDataSource.create(photoEntity)
    }
    
    func addPhotos(_ photos: [Photo]) async throws {
        try photoDataSource.create(photos.map { PhotoEntity($0) })
    }
    
    func updatePhoto(_ photo: Photo) async throws {
        try photoDataSource.update(PhotoEntity(photo))
    }
    
    func updatePhotos(_ photos: [Photo]) async throws {
        try photoDataSource.update(photos.map { PhotoEntity($0) })
    }
    
    func deletePhoto(_ photoId: UUID) async throws {
        try photoDataSource.delete(where: #Predicate { $0.id == photoId })
    }
    
    func deletePhotos(_ photoIds: [UUID]) async throws {
        let photoSet = Set(photoIds)
        
        try photoDataSource.delete(where: #Predicate { item in
            photoSet.contains(item.id)
        })
    }
    
    func deleteAllPhotos() async throws {
        try photoDataSource.deleteAll()
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
