//
//  ChildWidgetOption.swift
//  PicCharge
//
//  Created by 김도현 on 5/22/24.
//

import Foundation

struct ChildWidgetOption {
    // 목표로 설정한 시간 설정(byAdding에 따라 초, 분 시간 등이 될 수 있음)
    // ex)totalTime = 150이고, byAdding이 .hour이면 목표로 설정한 시간이 150시간이 됨
    static let totalTime = 130
    
    // 사진을 전송한 시간 설정
    static let photoSentDate = Date()

    // byAdding의 .second를 변경하여 분, 시간 등으로 시간 측정 단위를 변경 가능
    static func byAdding(value: Int, to date: Date) -> Date {
        return Calendar.current.date(byAdding: .second, value: value, to: date)!
    }
}