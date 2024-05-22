//
//  ServerModel.swift
//  PicCharge
//
//  Created by 이상현 on 5/18/24.
//

import Foundation
import FirebaseFirestoreSwift

enum ConnectionRequestStatus: String, Codable {
    case pending
    case accepted
    case rejected
}

struct ConnectionRequestsDTO: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore의 문서 ID와 매핑
    var from: String
    var to: String
    var status: ConnectionRequestStatus
    var requestDate: Date
}

struct ConnectionDTO: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore의 문서 ID와 매핑
    var connectedTo: [String]
}

struct PhotoDTO: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore의 문서 ID와 매핑
    var uploadBy: String
    var urlString: String
    var sharedWith: [String]
    var likeCount: Int
    var uploadDate: Date
    
    init(photo: Photo, sharedWith: [String]) {
        self.id = photo.id.uuidString
        self.uploadBy = photo.uploadBy
        self.urlString = photo.urlString
        self.sharedWith = sharedWith
        self.likeCount = photo.likeCount
        self.uploadDate = photo.uploadDate
    }
}
