//
//  LocalStorage.swift
//  PicCharge
//
//  Created by 남유성 on 12/30/24.
//

import Foundation
import SwiftData

protocol LocalStorage {
    associatedtype T
    
    func create(_ item: T) throws
    func create(_ items: [T]) throws
    func read(predicate: Predicate<T>?,
              sortDescriptors: SortDescriptor<T>...) throws -> [T]
    func update(_ item: T) throws
    func delete(_ item: T) throws
    func delete(where predicate: Predicate<T>) throws
}
