//
//  SwiftDataService.swift
//  PicCharge
//
//  Created by 남유성 on 12/31/24.
//

import Foundation
import SwiftData

final class SwiftDataService<T: PersistentModel> {
    
    private var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
}

extension SwiftDataService {
    func create(_ item: T) throws {
        let context = ModelContext(container)
        context.insert(item)
        try context.save()
    }
    
    func create(_ items: [T]) throws {
        let context = ModelContext(container)
        for item in items {
            context.insert(item)
        }
        try context.save()
    }
    
    func read(predicate: Predicate<T>? = nil,
              sortDescriptors: SortDescriptor<T>...,
              fetchLimit: Int? = nil) throws -> [T] {
        let context = ModelContext(container)
        
        var fetchDescriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        
        if let fetchLimit { fetchDescriptor.fetchLimit = fetchLimit }
        
        return try context.fetch(fetchDescriptor)
    }
    
    func update(_ item: T) throws {
        try create(item)
    }
    
    func update(_ items: [T]) throws {
        try create(items)
    }
    
    func deleteAll() throws {
        let context = ModelContext(container)
        try context.delete(model: T.self)
        try context.save()
    }
    
    func delete(where predicate: Predicate<T>) throws {
        let context = ModelContext(container)
        try context.delete(model: T.self, where: predicate)
        try context.save()
    }
}
