//
//  Photo.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import SwiftUI

struct Reaction: Equatable {
    var love: Int
    var fire: Int
    var star: Int
    var like: Int
    
    enum Kind {
        case love, fire, star, like
        
        var icon: Image {
            switch self {
            case .love: return Icon.loveReaction
            case .fire: return Icon.fireReaction
            case .star: return Icon.starReaction
            case .like: return Icon.likeReaction
            }
        }
    }
    
    mutating func increment(for kind: Kind) {
        switch kind {
        case .love: self.love += 1
        case .fire: self.fire += 1
        case .star: self.star += 1
        case .like: self.like += 1
        }
    }
}

@Observable
class Photo: Hashable, Identifiable {
    let id: UUID
    var uploadBy: String
    var uploadDate: Date
    var imgData: Data?
    var urlString: String?
    var reaction: Reaction
    var sharedWith: [String]
    
    init(id: UUID, uploadBy: String, uploadDate: Date, imgData: Data? = nil, urlString: String? = nil, reaction: Reaction, sharedWith: [String]) {
        self.id = id
        self.uploadBy = uploadBy
        self.uploadDate = uploadDate
        self.imgData = imgData
        self.urlString = urlString
        self.reaction = reaction
        self.sharedWith = sharedWith
    }
}

extension Photo {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Photo {
    convenience init(of user: User, imgData: Data) {
        self.init(
            id: UUID(),
            uploadBy: user.name,
            uploadDate: .now,
            imgData: imgData,
            reaction: .init(love: 0, fire: 0, star: 0, like: 0),
            sharedWith: user.connectedTo + [user.name]
        )
    }
}

enum PhotoSortOption {
    case uploadDate
}
