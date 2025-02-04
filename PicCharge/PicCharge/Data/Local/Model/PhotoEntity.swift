//
//  PhotoEntity.swift
//  PicCharge
//
//  Created by 남유성 on 5/23/24.
//

import SwiftUI
import SwiftData

@Model
final class PhotoEntity {
    @Attribute(.unique) var id: UUID
    var uploadBy: String // 유저 닉네임
    var uploadDate: Date // 업로드 날짜
    var urlString: String?
    var loveCount: Int // 좋아요 개수
    var fireCount: Int // 좋아요 개수
    var starCount: Int // 좋아요 개수
    var likeCount: Int // 좋아요 개수
    var sharedWith: [String] // 공유 받는 유저의 닉네임
            
    @Attribute(.externalStorage) var imgData: Data // 이미지 데이터
    
    init(
        id: UUID = UUID(),
        uploadBy: String,
        uploadDate: Date = Date(),
        urlString: String?,
        loveCount: Int = 0,
        fireCount: Int = 0,
        starCount: Int = 0,
        likeCount: Int = 0,
        sharedWith: [String],
        imgData: Data
    ) {
        self.id = id
        self.uploadBy = uploadBy
        self.uploadDate = uploadDate
        self.urlString = urlString
        self.loveCount = loveCount
        self.fireCount = fireCount
        self.starCount = starCount
        self.likeCount = likeCount
        self.sharedWith = sharedWith
        self.imgData = imgData
    }
    
    // TODO: - 제거
    convenience init(from photo: PhotoDTO_V0, imgData: Data) {
        self.init(
            id: UUID(uuidString: photo.id ?? UUID().uuidString) ?? UUID(),
            uploadBy: photo.uploadBy,
            uploadDate: photo.uploadDate,
            urlString: photo.urlString,
            loveCount: 0,
            fireCount: 0,
            starCount: 0,
            likeCount: photo.likeCount,
            sharedWith: photo.sharedWith,
            imgData: imgData
        )
    }
}

extension PhotoEntity: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoEntity, rhs: PhotoEntity) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PhotoEntity: DomainConvertible {
    convenience init(_ domain: Photo) {
        self.init(
            id: domain.id,
            uploadBy: domain.uploadBy,
            uploadDate: domain.uploadDate,
            urlString: domain.urlString,
            loveCount: domain.reaction.love,
            fireCount: domain.reaction.fire,
            starCount: domain.reaction.star,
            likeCount: domain.reaction.like,
            sharedWith: domain.sharedWith,
            imgData: domain.imgData ?? Data()
        )
    }
    
    func toDomain() -> Photo {
        Photo(
            id: id,
            uploadBy: uploadBy,
            uploadDate: uploadDate,
            imgData: imgData,
            urlString: urlString,
            reaction: .init(
                love: loveCount,
                fire: fireCount,
                star: starCount,
                like: likeCount
            ),
            sharedWith: sharedWith
        )
    }
}
