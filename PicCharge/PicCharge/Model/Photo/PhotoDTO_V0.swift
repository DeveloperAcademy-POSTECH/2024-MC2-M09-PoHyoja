//
//  Photo.swift
//  PicCharge
//
//  Created by 남유성 on 5/27/24.
//

import Foundation
import FirebaseFirestoreSwift

struct PhotoDTO_V0: Identifiable, Codable {
    @DocumentID var id: String?
    var uploadBy: String
    var uploadDate: Date
    var urlString: String
    var likeCount: Int
    var sharedWith: [String]
    
    init(from photoForSwiftData: PhotoEntity, urlString: String) {
        self.id = photoForSwiftData.id.uuidString
        self.uploadBy = photoForSwiftData.uploadBy
        self.uploadDate = photoForSwiftData.uploadDate
        self.urlString = urlString
        self.likeCount = photoForSwiftData.likeCount
        self.sharedWith = photoForSwiftData.sharedWith
    }
}

extension PhotoDTO_V0: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoDTO_V0, rhs: PhotoDTO_V0) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PhotoDTO_V0 {
    func toV1() -> PhotoDTO_V1 {
        return PhotoDTO_V1.init(
            id: id,
            uploadBy: uploadBy,
            uploadDate: uploadDate,
            urlString: urlString,
            reactions: .init(love: 0, fire: 0, star: 0, like: likeCount),
            sharedWith: sharedWith
        )
    }
}
