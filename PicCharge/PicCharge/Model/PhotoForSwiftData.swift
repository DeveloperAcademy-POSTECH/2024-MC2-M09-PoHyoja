//
//  PhotoForSwiftData.swift
//  PicCharge
//
//  Created by 남유성 on 5/23/24.
//

import SwiftUI
import SwiftData

@Model
final class PhotoForSwiftData {
    @Attribute(.unique) var id: UUID
    var uploadBy: String // 유저 닉네임
    var uploadDate: Date // 업로드 날짜
    var likeCount: Int // 좋아요 개수
    var sharedWith: [String] // 공유 받는 유저의 닉네임
            
    @Attribute(.externalStorage) var imgData: Data // 이미지 데이터
    
    init(
        id: UUID = UUID(),
        uploadBy: String,
        uploadDate: Date = Date(),
        likeCount: Int = 0,
        sharedWith: [String],
        imgData: Data
    ) {
        self.id = id
        self.uploadBy = uploadBy
        self.uploadDate = uploadDate
        self.likeCount = likeCount
        self.sharedWith = sharedWith
        self.imgData = imgData
    }
}
