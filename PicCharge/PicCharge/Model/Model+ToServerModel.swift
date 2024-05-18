//
//  Model+ToServerModel.swift
//  PicCharge
//
//  Created by 이상현 on 5/18/24.
//
import Foundation

extension Role {
    func toServerRole() -> ServerRole {
        switch self {
        case .parent:
            return .parent
        case .child:
            return .child
        }
    }
}

extension ServerRole {
    func toRole() -> Role {
        switch self {
        case .parent:
            return .parent
        case .child:
            return .child
        }
    }
}

extension Parent {
    func toServerUser() -> ServerUser {
        return ServerUser(id: id.uuidString, role: role.toServerRole(), email: email, uploadCycle: nil)
    }
}

extension Child {
    func toServerUser() -> ServerUser {
        return ServerUser(id: id.uuidString, role: role.toServerRole(), email: email, uploadCycle: uploadCycle)
    }
}

extension ServerUser {
    func toParent() -> Parent? {
        guard let role = role?.toRole(), role == .parent, let id = id else { return nil }
        return Parent(id: UUID(uuidString: id)!, email: email, role: role, connectedTo: [])
    }
    
    func toChild() -> Child? {
        guard let role = role?.toRole(), role == .child, let id = id, let uploadCycle = uploadCycle else { return nil }
        return Child(id: UUID(uuidString: id)!, email: email, role: role, connectedTo: [], uploadCycle: uploadCycle)
    }
}

extension Photo {
    func toServerPhoto() -> ServerPhoto {
        return ServerPhoto(id: id.uuidString, uploadBy: uploadBy.uuidString, url: urlString, sharedWith: [], likeCount: likeCount, uploadDate: uploadDate)
    }
}

extension ServerPhoto {
    func toLocalPhoto() -> Photo? {
        guard let id = id, let uploadBy = UUID(uuidString: uploadBy) else { return nil }
        return Photo(id: UUID(uuidString: id)!, uploadBy: uploadBy, uploadDate: uploadDate, urlString: url, likeCount: likeCount)
    }
}
