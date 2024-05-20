//
//  Model.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/16/24.
//

import Foundation
import FirebaseFirestoreSwift

enum Role: String, CaseIterable, Codable {
    case parent
    case child
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var role: Role
    var connectedTo: [User]
    var uploadCycle: Int?
}

//extension User {
//    init(from dto: UserDTO) {
//        self.id = dto.id
//        self.email = dto.email
//        self.role = dto.role
//        self.connectedTo = [] // TODO: 연결된 자식 User 넣기
//        self.uploadCycle = dto.uploadCycle ?? 3
//    }
//}


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

extension Photo {
    init(from dto: PhotoDTO) throws {
        guard let idString = dto.id, let id = UUID(uuidString: idString) else {
            throw FirestoreServiceError.invalidUUID
        }
        self.id = id
        self.uploadBy = dto.uploadBy
        self.uploadDate = dto.uploadDate
        self.urlString = dto.urlString
        self.likeCount = dto.likeCount
    }
}
