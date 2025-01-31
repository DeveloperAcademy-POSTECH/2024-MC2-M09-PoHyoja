//
//  Photo+Mock.swift
//  PicCharge
//
//  Created by 남유성 on 1/31/25.
//

import UIKit

extension Photo {
    static let onlyUrlMock1 = Photo(id: UUID(),
                               uploadBy: "Mock 자식",
                               uploadDate: .now,
                               urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
                               reaction: .init(love: 0, fire: 0, star: 0, like: 0),
                               sharedWith: ["Mock 자식", "Mock 부모"])
    
    static let onlyUrlMock2 = Photo(id: UUID(),
                               uploadBy: "Mock 자식",
                               uploadDate: .now,
                               urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
                               reaction: .init(love: 0, fire: 0, star: 0, like: 0),
                                    sharedWith: ["Mock 자식", "Mock 부모"])
    
    static let onlyUrlMock3 = Photo(id: UUID(),
                               uploadBy: "Mock 자식",
                               uploadDate: .now,
                               urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
                               reaction: .init(love: 0, fire: 0, star: 0, like: 0),
                               sharedWith: ["Mock 자식", "Mock 부모"])
    
    static let withDataMock1 = Photo(id: UUID(),
                                uploadBy: "Mock 자식",
                                uploadDate: .now,
                                imgData: UIImage(resource: .logoLarge).pngData()!,
                                urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
                                reaction: .init(love: 0, fire: 0, star: 0, like: 0),
                                sharedWith: ["Mock 자식", "Mock 부모"])
    
    static let withDataMock2 = Photo(id: UUID(),
                                uploadBy: "Mock 자식",
                                uploadDate: .now,
                                imgData: UIImage(resource: .logoLarge).pngData()!,
                                urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
                                reaction: .init(love: 0, fire: 0, star: 0, like: 0),
                                sharedWith: ["Mock 자식", "Mock 부모"])
    
    static let withDataMock3 = Photo(id: UUID(),
                                uploadBy: "Mock 자식",
                                uploadDate: .now,
                                imgData: UIImage(resource: .logoLarge).pngData()!,
                                urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
                                reaction: .init(love: 0, fire: 0, star: 0, like: 0),
                                sharedWith: ["Mock 자식", "Mock 부모"])
    
    static let oneDayAgo = Photo(
            id: UUID(),
            uploadBy: "Mock 자식",
            uploadDate: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
            imgData: UIImage(resource: .logoLarge).pngData()!,
            urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
            reaction: .init(love: 0, fire: 0, star: 0, like: 0),
            sharedWith: ["Mock 자식", "Mock 부모"]
        )
        
        static let twoDayAgo = Photo(
            id: UUID(),
            uploadBy: "Mock 자식",
            uploadDate: Calendar.current.date(byAdding: .day, value: -2, to: .now)!,
            imgData: UIImage(resource: .logoLarge).pngData()!,
            urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
            reaction: .init(love: 0, fire: 0, star: 0, like: 0),
            sharedWith: ["Mock 자식", "Mock 부모"]
        )
        
        static let threeDaysAgo = Photo(
            id: UUID(),
            uploadBy: "Mock 자식",
            uploadDate: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
            imgData: UIImage(resource: .logoLarge).pngData()!,
            urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
            reaction: .init(love: 0, fire: 0, star: 0, like: 0),
            sharedWith: ["Mock 자식", "Mock 부모"]
        )
        
        static let oneWeekAgo = Photo(
            id: UUID(),
            uploadBy: "Mock 자식",
            uploadDate: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now)!,
            imgData: UIImage(resource: .logoLarge).pngData()!,
            urlString: "https://firebasestorage.googleapis.com:443/v0/b/piccharge-afbc7.appspot.com/o/photos%2F%EC%97%90%EC%9D%B4%EC%8A%A4%2F008373A3-1175-42F2-8C73-F381C363A57D.jpg?alt=media&token=7849bedc-28a2-4316-bfc4-81c86fa284a8",
            reaction: .init(love: 0, fire: 0, star: 0, like: 0),
            sharedWith: ["Mock 자식", "Mock 부모"]
        )
}
