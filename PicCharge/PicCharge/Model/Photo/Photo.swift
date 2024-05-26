//
//  Photo.swift
//  PicCharge
//
//  Created by 남유성 on 5/27/24.
//

import Foundation
import FirebaseFirestoreSwift

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
