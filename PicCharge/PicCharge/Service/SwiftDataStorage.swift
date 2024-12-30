//
//  SwiftDataStorage.swift
//  PicCharge
//
//  Created by 남유성 on 12/31/24.
//

import Foundation
import SwiftData

protocol SwiftDataStorage: LocalStorage {
    associatedtype T = PersistentModel
    associatedtype PredicateType = Predicate<T>
    associatedtype SortDescriptorType = SortDescriptor<T>
    
    var container: ModelContainer { get }
}

extension SwiftDataStorage {
    func create<T: PersistentModel>(_ item: T) throws {
        let context = ModelContext(container)
        context.insert(item)
        try context.save()
    }
    
    func create<T: PersistentModel>(_ items: [T]) throws {
        let context = ModelContext(container)
        for item in items {
            context.insert(item)
        }
        try context.save()
    }
    
    func read<T: PersistentModel>(predicate: Predicate<T>? = nil,
                                  sortDescriptors: SortDescriptor<T>...) throws -> [T] {
        let context = ModelContext(container)
        
        let fetchDescriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        
        return try context.fetch(fetchDescriptor)
    }
    
    func update<T: PersistentModel>(_ item: T) throws {
        let context = ModelContext(container)
        try context.save()
    }
    
    func delete<T: PersistentModel>(_ item: T) throws {
        let context = ModelContext(container)
        context.delete(item)
        try context.save()
    }
}
