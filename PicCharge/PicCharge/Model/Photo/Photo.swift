//
//  Photo.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import Foundation

struct Photo {
    let id: UUID
    var uploadBy: String
    var uploadDate: Date
    var imgData: Data?
    var urlString: String?
    var likeCount: Int
    var sharedWith: [String]
}
