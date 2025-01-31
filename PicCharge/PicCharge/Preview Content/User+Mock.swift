//
//  User+Mock.swift
//  PicCharge
//
//  Created by 남유성 on 1/31/25.
//

import Foundation

extension User {
    static let childMock = User(name: "Mock 자식",
                                role: .child,
                                email: "child@Mock.com",
                                connectedTo: ["Mock 부모"])
    
    static let parentMock = User(name: "Mock 부모",
                                 role: .child,
                                 email: "parent@Mock.com",
                                 connectedTo: ["Mock 자식"])
    
    static let NCchildMock = User(name: "Mock NC자식",
                                  role: .child,
                                  email: "NCchild@Mock.com",
                                  connectedTo: [])
    
    static let NCparentMock = User(name: "Mock NC부모",
                                   role: .parent,
                                   email: "NCparent@Mock.com",
                                   connectedTo: [])
}
