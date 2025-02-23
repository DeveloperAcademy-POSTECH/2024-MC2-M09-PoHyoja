//
//  EntityDataSource.swift
//  PicCharge
//
//  Created by 남유성 on 12/31/24.
//

import Foundation
import SwiftData

@ModelActor
actor EntityDataSource<T: PersistentModel> {
    
    enum Operation {
        case create([T])
        case update([T])
        case delete(Predicate<T>?)
        case deleteAll
    }
    
    func perform(_ operations: Operation...) throws {
        for operation in operations {
            
            switch operation {
            case .create(let items):
                items.forEach { modelContext.insert($0) }
                
            case .update(let items):
                items.forEach { modelContext.insert($0) } // .unique 옵션 변수로 업데이트 처리
                
            case .delete(let predicate):
                try modelContext.delete(model: T.self, where: predicate)
                
            case .deleteAll:
                try modelContext.delete(model: T.self)
            }
        }
        
        try modelContext.save()
    }
    
    func fetch(predicate: Predicate<T>? = nil,
               sortDescriptors: SortDescriptor<T>...,
               fetchLimit: Int? = nil) throws -> [T] {
        
        var fetchDescriptor = FetchDescriptor<T>(predicate: predicate,
                                                 sortBy: sortDescriptors)
        
        if let fetchLimit { fetchDescriptor.fetchLimit = fetchLimit }
        
        return try modelContext.fetch(fetchDescriptor)
    }
}
