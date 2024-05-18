//
//  ServerModel.swift
//  PicCharge
//
//  Created by 이상현 on 5/18/24.
//

import Foundation
import FirebaseFirestoreSwift

enum ServerRole: String, CaseIterable, Codable {
    case parent
    case child
}

struct ServerUser: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore의 문서 ID와 매핑
    var role: ServerRole?
    var email: String
    var uploadCycle: Int?
}

enum ServerConnectionRequestStatus: String, Codable {
    case pending
    case accepted
    case rejected
}

struct ServerConnectionRequest: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore의 문서 ID와 매핑
    var from: String
    var to: String
    var status: ServerConnectionRequestStatus
    var requestDate: Date
}

struct ServerConnection: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore의 문서 ID와 매핑
    var connectedTo: [String]
}

struct ServerPhoto: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore의 문서 ID와 매핑
    var uploadBy: String
    var url: String
    var sharedWith: [String]
    var likeCount: Int
    var uploadDate: Date
}
