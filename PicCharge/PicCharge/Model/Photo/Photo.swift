//
//  Photo.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import Foundation

struct Photo: Hashable, Identifiable {
    let id: UUID
    var uploadBy: String
    var uploadDate: Date
    var imgData: Data?
    var urlString: String?
    var likeCount: Int
    var sharedWith: [String]
}

extension Photo {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
}

#if DEBUG
import UIKit

extension Photo {
    static let mocks: [Photo] = Array(1...4).map {
        return Photo(
            id: UUID(),
            uploadBy: "Mock \($0)",
            uploadDate: .now.addingTimeInterval(Double($0) * 3600),
            imgData: UIImage(resource: .logoLarge).pngData()!,
            urlString: "https://picsum.photos/200",
            likeCount: 0,
            sharedWith: []
        )
    }
    
    static let mock: Photo = Photo(
        id: UUID(),
        uploadBy: "Mock",
        uploadDate: .now.addingTimeInterval(Double.random(in: 0...10) * 3600),
        imgData: UIImage(resource: .logoLarge).pngData()!,
        urlString: "https://picsum.photos/200",
        likeCount: 0,
        sharedWith: []
    )
}
#endif

enum PhotoSortOption {
    case uploadDate
}
