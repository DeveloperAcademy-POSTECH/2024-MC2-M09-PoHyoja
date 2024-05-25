//
//  Model.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/16/24.
//

import Foundation
import FirebaseFirestoreSwift

/**
 users
     `userID`: 아이디 (자동생성)
     
     - name (string): 이름 (고유해야 한다.)
     - role (string): 역할 (parent, child)
     - email(string): 이메일
     - connectedTo: ([String]): 연결된 유저의 이름
     - uploadCycle(null/number): 자식 역할일 경우 며칠에 한번 사진 올릴지 목표치
 
 예시
 ```json
 {
   "users": {
     "KDLOoKT7ishJQyofa3pITE8qh9f1": {
         "name": "조페더",
       "role": "parent",
       "email": "parent@google.com"
       "connectedTo": ["에이스"]
       "uploadCycle": null
     },
     "goNulJ3kBFOAHwDSGt0sRuT1JbD3": {
         "name": "에이스"
       "role": "child",
       "email": "child@naver.com"
       "connectedTo": ["조페더"]
       "uploadCycle": 3
     },
     ...
   }
 }
 ```
 */
struct User: Identifiable, Codable {
    @DocumentID var id: String? // Firestore의 문서 ID와 매핑
    var name: String
    var role: Role
    var email: String
    var connectedTo: [String] = []
    var uploadCycle: Int? = nil
}

/**
 photos
     `photoID`: 사진의 고유 아이디 (자동생성)
     
     - uploadBy(string): 업로드한 유저의 닉네임
     - urlString(string): 사진의 url 주소
     - sharedWith([string]): 공유받은 유저의 닉네임 배열
     - likeCount(number): 좋아요 개수
     - uploadDate(timestamp): 올린 시간
 
 예시
 ```json
 {
   "photos": {
     "photoID1": {
       "uploadBy": "에이스",
       "urlString": "https://..",
       "sharedWith": ["조페더"],
       "likeCount": 123,
       "uploadDate": "2024-05-12T08:00:00Z"
     },
     ...
   }
 }
 ```
 */
struct Photo: Identifiable, Codable {
    // 목업 생성 예시 let photos = Photo.mockup.chunked(into: 3)
    
    @DocumentID var id: String?
    var uploadBy: String
    var uploadDate: Date
    var urlString: String
    var likeCount: Int
    var sharedWith: [String]
    
    init(id: String? = nil, uploadBy: String, uploadDate: Date, urlString: String, likeCount: Int, sharedWith: [String]) {
        self.id = id
        self.uploadBy = uploadBy
        self.uploadDate = uploadDate
        self.urlString = urlString
        self.likeCount = likeCount
        self.sharedWith = sharedWith
    }
    
    init(from photoForSwiftData: PhotoForSwiftData, urlString: String) {
        self.id = photoForSwiftData.id.uuidString
        self.uploadBy = photoForSwiftData.uploadBy
        self.uploadDate = photoForSwiftData.uploadDate
        self.urlString = urlString
        self.likeCount = photoForSwiftData.likeCount
        self.sharedWith = photoForSwiftData.sharedWith
    }
    
    static let mockup: [Photo] = {
        let uploadBy = "TestID"
        let uploadDate = Date()
        let urlString = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsNICnidsWi7x-UmXHlkEz-8VUeKwmJSg86Xli4i-26A&s"
        
        return (0..<100).map {
            Photo(id: UUID().uuidString, uploadBy: uploadBy, uploadDate: uploadDate, urlString: urlString, likeCount: $0, sharedWith: [])
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

enum Role: String, CaseIterable, Codable {
    case parent
    case child
}

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
