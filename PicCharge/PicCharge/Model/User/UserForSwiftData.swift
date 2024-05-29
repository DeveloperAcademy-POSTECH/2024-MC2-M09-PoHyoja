//
//  UserForSwiftData.swift
//  PicCharge
//
//  Created by 남유성 on 5/23/24.
//

import SwiftUI
import SwiftData

@Model
final class UserForSwiftData {
    @Attribute(.unique) var name: String
    var role: Role
    var email: String
    var connectedTo: [String]
    var uploadCycle: Int?
    
//    @Relationship(deleteRule: .cascade) var photos: [PhotoForSwiftData]
    
    init(
        name: String,
        role: Role,
        email: String,
        connectedTo: [String] = [],
        uploadCycle: Int? = nil
//        photos: [PhotoForSwiftData] = []
    ) {
        self.name = name
        self.role = role
        self.email = email
        self.connectedTo = connectedTo
        self.uploadCycle = uploadCycle
//        self.photos = photos
    }
}
