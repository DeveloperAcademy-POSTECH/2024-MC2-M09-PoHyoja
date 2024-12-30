//
//  File.swift
//  PicCharge
//
//  Created by 남유성 on 12/30/24.
//

import Foundation
import SwiftData

protocol LocalStorage {
    associatedtype T
    associatedtype PredicateType
    associatedtype SortDescriptorType
    
    func create(_ item: T) throws
    func create(_ items: [T]) throws
    func read(predicate: PredicateType?,
              sortDescriptors: SortDescriptorType...) throws -> [T]
    func update(_ item: T) throws
    func delete(_ item: T) throws
}
