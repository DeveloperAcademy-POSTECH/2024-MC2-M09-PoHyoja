//
//  Photo.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import Foundation

struct Reaction: Equatable {
    var love: Int
    var fire: Int
    var star: Int
    var like: Int
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

import UIKit

extension Photo {
    static let mocks: [Photo] = Array(1...4).map {
        return Photo(
            id: UUID(),
            uploadBy: "Mock \($0)",
            uploadDate: .now.addingTimeInterval(Double($0) * 3600),
            imgData: UIImage(resource: .logoLarge).pngData()!,
            urlString: "https://picsum.photos/200",
            reaction: .init(love: 0, fire: 0, star: 0, like: 0),
            sharedWith: []
        )
    }
    
    static let mock: Photo = Photo(
        id: UUID(),
        uploadBy: "Mock",
        uploadDate: .now.addingTimeInterval(Double.random(in: 0...10) * 3600),
        imgData: UIImage(resource: .logoLarge).pngData()!,
        urlString: "https://picsum.photos/200",
        reaction: .init(love: 0, fire: 0, star: 0, like: 0),
        sharedWith: []
    )
    
    static let dataInRemote: Photo = Photo(
        id: UUID(),
        uploadBy: "Mock",
        uploadDate: .now.addingTimeInterval(Double.random(in: 0...10) * 3600),
        imgData: nil,
        urlString:
            "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
        reaction: .init(love: 0, fire: 0, star: 0, like: 0),
        sharedWith: []
    )
    
    static let dataInLocal: Photo = Photo(
        id: UUID(),
        uploadBy: "Mock",
        uploadDate: .now.addingTimeInterval(Double.random(in: 0...10) * 3600),
        imgData: UIImage(resource: .logoLarge).pngData()!,
        urlString: nil,
        reaction: .init(love: 0, fire: 0, star: 0, like: 0),
        sharedWith: []
    )
}

enum PhotoSortOption {
    case uploadDate
}
