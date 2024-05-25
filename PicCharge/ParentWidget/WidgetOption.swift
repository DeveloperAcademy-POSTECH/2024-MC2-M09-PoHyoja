//
//  WidgetOption.swift
//  PicCharge
//
//  Created by 김도현 on 5/22/24.
//

import Foundation

import Foundation

struct ChildWidgetOption {
    // 시간 측정 단위 설정 (초, 분, 시간 등)
    // .second를 변경하여 분, 시간 등으로 시간 측정 단위를 변경 가능
    static let timeUnit: Calendar.Component = .second
    
    
    // 목표로 설정한 시간 설정(timeUnit에 따라 초, 분, 시간이 될 수 있음)
    // ex) timeUnit이 .hour이고 totalTime = 150이면 목표로 설정한 시간이 150시간이 됨
    static let targetTime = 18
    
    
    // 사진을 전송한 시간 설정
    static let photoSentDate = Date()
}
