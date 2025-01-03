//
//  FirebaseServiceError.swift
//  PicCharge
//
//  Created by 남유성 on 1/4/25.
//

import Foundation

enum FirebaseServiceError: Error, Equatable {
    case invalidQuery
    
    case invalidUserName
    case invalidUserId
    case userNotExists
    case userAlreadyExists
    case invalidUserDTOFormat
    
    case invalidPhotoData
    case invalidDownloadURL
    case invalidPhotoDTOFormat
    
    case addUserFailed(error: String)
    case deleteUserFailed(error: String)
    
    case uploadPhotoFailed(error: String)
    case downloadPhotoFailed(error: String)
    case updatePhotoFailed(error: String)
    case deletePhotoFailed(error: String)
}

extension FirebaseServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "잘못된 쿼리입니다."
            
        case .userAlreadyExists:
            return "이미 존재하는 사용자입니다."
        case .userNotExists:
            return "존재하지 않은 사용자입니다."
        case .invalidUserName:
            return "유효하지 않은 사용자 이름입니다."
        case .invalidUserId:
            return "유효하지 않은 사용자 ID입니다."
        case .invalidUserDTOFormat:
            return "사용자 데이터 형식이 잘못되었습니다."
            
        case .invalidPhotoData:
            return "유효하지 않은 사진 데이터입니다."
        case .invalidDownloadURL:
            return "유효하지 않은 다운로드 URL입니다."
        case .invalidPhotoDTOFormat:
            return "사진 데이터 형식이 잘못되었습니다."
            
        case .uploadPhotoFailed(let error):
            return "사진 업로드에 실패했습니다. Error: \(error)"
        case .downloadPhotoFailed(let error):
            return "사진 다운로드에 실패했습니다. Error: \(error)"
        case .updatePhotoFailed(let error):
            return "사진 업데이트에 실패했습니다. Error: \(error)"
        case .deletePhotoFailed(let error):
            return "사진 삭제에 실패했습니다. Error: \(error)"
        case .deleteUserFailed(let error):
            return "유저 삭제에 실패했습니다. Error: \(error)"
        case .addUserFailed(let error):
            return "유저 생성에 실패했습니다. Error: \(error)"
        }
    }
}
