//
//  ConnectionRequests.swift
//  PicCharge
//
//  Created by 남유성 on 5/27/24.
//

import Foundation
import FirebaseFirestoreSwift

enum ConnectionRequestStatus: String, Codable {
    case pending
    case accepted
    case rejected
}

/**
 connectionRequests
     `requestID`: 아이디 (자동생성)
     
     - from(string): 요청한 유저의 이름
     - to(string): 요청받은 유저의 이름
     - status(string): 요청 상태 (pending, accepted, rejected)
     - requestDate(timestamp): 요청 날짜
 
 예시
 ```json
 {
   "connectionRequests": {
     "requestID1": {
       "from": "조페더",
       "to": "에이스",
       "status": "pending"
       "requestDate": "2024-05-12T08:00:00Z"
     },
     ...
   }
 }
 ```
 */
struct ConnectionRequestsDTO: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore의 문서 ID와 매핑
    var from: String
    var to: String
    var status: ConnectionRequestStatus
    var requestDate: Date
}
