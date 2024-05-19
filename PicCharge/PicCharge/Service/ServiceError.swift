//
//  ServiceError.swift
//  PicCharge
//
//  Created by 이상현 on 5/19/24.
//

import Foundation

enum FirestoreServiceError: Error {
    case invalidUserId
    case userNotFound
}
