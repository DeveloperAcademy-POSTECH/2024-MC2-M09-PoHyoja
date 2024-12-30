//
//  UserLocalStorage.swift
//  PicCharge
//
//  Created by 남유성 on 12/31/24.
//

import Foundation
import SwiftData

final class UserLocalStorage: SwiftDataStorage {
    typealias T = UserEntity
    
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func delete(_ userName: String) throws {
        let context = ModelContext(container)
        try context.delete(model: UserEntity.self, where: #Predicate { user in
            user.name == userName
        })
        try context.save()
    }
}
