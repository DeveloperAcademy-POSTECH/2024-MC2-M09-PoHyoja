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
}
