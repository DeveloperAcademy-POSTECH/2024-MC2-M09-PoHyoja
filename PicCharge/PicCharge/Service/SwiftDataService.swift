//
//  SwiftDataService.swift
//  PicCharge
//
//  Created by 남유성 on 12/31/24.
//

import Foundation
import SwiftData

final class SwiftDataService: LocalStorageService {
    
    private let userStorage: UserLocalStorage
    private let photoStorage: PhotoLocalStorage

    init(isStoredInMemoryOnly: Bool = false) throws {
        let schema = Schema([
            UserEntity.self,
            PhotoEntity.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            userStorage = UserLocalStorage(container: container)
            photoStorage = PhotoLocalStorage(container: container)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }
}

// MARK: - User Entity
extension SwiftDataService {
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
    
    func deleteUser(_ name: String) async throws {
        try userStorage.delete(name)
    }
}

// MARK: - Photo Entity
extension SwiftDataService {
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
    
    func deletePhoto(_ photoId: UUID) async throws {
        try photoStorage.delete(photoId)
    }
}

extension SwiftDataService {
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
