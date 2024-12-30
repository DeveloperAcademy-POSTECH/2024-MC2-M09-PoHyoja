//
//  PhotoLocalStorage.swift
//  PicCharge
//
//  Created by 남유성 on 12/31/24.
//

import Foundation
import SwiftData

final class PhotoLocalStorage: SwiftDataStorage {
    typealias T = PhotoEntity
    
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func delete(_ photoId: UUID) throws {
        let context = ModelContext(container)
        try context.delete(model: PhotoEntity.self, where: #Predicate { photo in
            photo.id == photoId
        })
        try context.save()
    }
}
