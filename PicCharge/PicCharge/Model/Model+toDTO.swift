//
//  Model+toDTO.swift
//  PicCharge
//
//  Created by 이상현 on 5/19/24.
//

import Foundation

extension Parent {
    init(from dto: UserDTO) {
        self.id = dto.id
        self.email = dto.email
        self.role = dto.role ?? .parent
        self.connectedTo = [] // TODO: 연결된 자식 아이디 넣기
    }
}

extension Child {
    init(from dto: UserDTO) {
        self.id = dto.id
        self.email = dto.email
        self.role = dto.role ?? .child
        self.connectedTo = [] // TODO: 연결된 부모 아이디 넣기
        self.uploadCycle = dto.uploadCycle ?? 3
    }
}

extension Photo {
    init(from dto: PhotoDTO) throws {
        guard let idString = dto.id, let id = UUID(uuidString: idString) else {
            throw FirestoreServiceError.invalidUUID
        }
        self.id = id
        self.uploadBy = dto.uploadBy
        self.uploadDate = dto.uploadDate
        self.urlString = dto.urlString
        self.likeCount = dto.likeCount
    }
}
