//
//  PhotoDTO_V1.swift
//  PicCharge
//
//  Created by 남유성 on 1/13/25.
//

import Foundation
import FirebaseFirestoreSwift

struct ReactionDTO_V1: Codable {
    var love: Int
    var fire: Int
    var star: Int
    var like: Int
}

struct PhotoDTO_V1: Identifiable, Codable {
    @DocumentID var id: String?
    var uploadBy: String
    var uploadDate: Date
    var urlString: String
    var reactions: ReactionDTO_V1
    var sharedWith: [String]
}

extension PhotoDTO_V1: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoDTO_V1, rhs: PhotoDTO_V1) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PhotoDTO_V1: DomainConvertible {
    init(_ domain: Photo, urlString: String) {
        self.init(
            id: domain.id.uuidString,
            uploadBy: domain.uploadBy,
            uploadDate: domain.uploadDate,
            urlString: urlString,
            reactions: .init(
                love: domain.reaction.love,
                fire: domain.reaction.fire,
                star: domain.reaction.star,
                like: domain.reaction.like
            ),
            sharedWith: domain.sharedWith
        )
    }
    
    func toDomain() -> Photo {
        return Photo(
            id: UUID(uuidString: id ?? "") ?? UUID(),
            uploadBy: uploadBy,
            uploadDate: uploadDate,
            urlString: urlString,
            reaction: .init(
                love: reactions.love,
                fire: reactions.fire,
                star: reactions.star,
                like: reactions.like
            ),
            sharedWith: sharedWith
        )
    }
}
