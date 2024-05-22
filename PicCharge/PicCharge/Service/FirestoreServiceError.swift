//
//  ServiceError.swift
//  PicCharge
//
//  Created by 이상현 on 5/19/24.
//

import Foundation

// 주석 추가
enum FirestoreServiceError: Error {
    case invalidUserId
    case userNotFound
    case invalidUserRole
    case invalidUUID // Photo 생성시에 id 문자열이 UUID 로 변환 실패
    case documentNotFound
    case decodingError
    case userAlreadyExists // 유저 회원가입시 아이디 중복일경우 발생하는 예외
    case invalidRequestId // 연결 요청시 아이디가 일치하지 않을 경우
    case requestNotFound
    case invalidRequest
}

extension FirestoreServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "제공된 사용자 ID가 유효하지 않습니다."
        case .userNotFound:
            return "데이터베이스에서 사용자를 찾을 수 없습니다."
        case .invalidUserRole:
            return "제공된 사용자 역할이 유효하지 않습니다."
        case .invalidUUID:
            return "제공된 ID 문자열을 UUID로 변환하는 데 실패했습니다."
        case .documentNotFound:
            return "요청한 문서를 데이터베이스에서 찾을 수 없습니다."
        case .decodingError:
            return "데이터베이스에서 데이터를 디코딩하는 데 실패했습니다."
        case .userAlreadyExists:
            return "동일한 ID를 가진 사용자가 이미 존재합니다."
        case .invalidRequestId:
            return "제공된 요청 ID가 일치하지 않습니다."
        case .requestNotFound:
            return "연결 요청을 찾지 못했습니다."
        case .invalidRequest:
            return "잘못된 연결 요청입니다."
        }
    }
}
