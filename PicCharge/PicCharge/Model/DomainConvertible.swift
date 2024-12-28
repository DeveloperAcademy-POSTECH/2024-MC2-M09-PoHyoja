//
//  DomainConvertible.swift
//  PicCharge
//
//  Created by 남유성 on 12/28/24.
//

import Foundation

/// Domain 모델로 변경 가능한 프로토콜입니다.
protocol DomainConvertible {
    associatedtype DomainModel
    func toDomain() -> DomainModel
}
