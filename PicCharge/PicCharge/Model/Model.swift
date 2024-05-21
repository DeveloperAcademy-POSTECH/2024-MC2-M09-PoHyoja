//
//  Model.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/16/24.
//

import Foundation

enum Role: String, CaseIterable, Codable {
    case parent
    case child
}

protocol User {
    var id: String? { get }
    var email: String { get }
    var role: Role { get }
    var connectedTo: [User] { get set }
}

struct Parent: User {
    var id: String?
    var email: String
    var role: Role
    var connectedTo: [User]
}

struct Child: User {
    var id: String?
    var email: String
    var role: Role
    var connectedTo: [User]
    
    var uploadCycle: Int
}

struct Photo: Identifiable {
    // 목업 생성 예시 let photos = Photo.mockup.chunked(into: 3)
    
    let id: UUID
    var uploadBy: String
    var uploadDate: Date
    var urlString: String
    var likeCount: Int
    
    static let mockup: [Photo] = {
        let uploadBy = "TestID"
        let uploadDate = Date()
        let urlString = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsNICnidsWi7x-UmXHlkEz-8VUeKwmJSg86Xli4i-26A&s"
        
        return (0..<100).map {
            Photo(id: UUID(), uploadBy: uploadBy, uploadDate: uploadDate, urlString: urlString, likeCount: $0)
        }
    }()
}

extension Photo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
}
