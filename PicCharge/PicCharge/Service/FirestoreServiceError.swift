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
}
