//
//  User.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import Foundation

struct User {
    var name: String
    var role: Role
    var email: String
    var connectedTo: [String]
    var uploadCycle: Int?
    
    init(
        name: String,
        role: Role,
        email: String,
        connectedTo: [String],
        uploadCycle: Int? = nil
    ) {
        self.name = name
        self.role = role
        self.email = email
        self.connectedTo = connectedTo + [name]
        self.uploadCycle = uploadCycle
    }
}

extension User {
    var isConnected: Bool { !connectedTo.isEmpty }
}
