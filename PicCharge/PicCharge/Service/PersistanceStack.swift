//
//  PersistanceStack.swift
//  PicCharge
//
//  Created by 남유성 on 1/7/25.
//

import SwiftData

final class PersistanceStack {
    let container: ModelContainer
    
    init(isMemoryOnly: Bool = false) throws {
        let schema = Schema([
            UserEntity.self,
            PhotoEntity.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isMemoryOnly)
        
        do {
            self.container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
