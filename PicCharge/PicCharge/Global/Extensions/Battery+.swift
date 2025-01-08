//
//  Battery+.swift
//  PicCharge
//
//  Created by 김도현 on 1/2/25.
//

import Foundation
import SwiftUI

extension Date {
    func calculateBatteryPercentage(uploadCycle: Int, lastUploadDate: Date?) -> Double {
        guard let lastUploadDate = lastUploadDate else {
            return 100.0
        }
        
        let currentTime = self
        let timeElapsed = currentTime.timeIntervalSince(lastUploadDate) // 경과 시간
        let uploadCycleDays = Double(uploadCycle)
        let uploadCycleSeconds = uploadCycleDays * 24 * 3600
        
        // 배터리 백분율 계산, 1프로 이하는 0으로 고정
        let currentPercentage = max(100.0 - (100 * timeElapsed / uploadCycleSeconds), 0)
        
        return round(currentPercentage)
    }
}

// 배터리 게이지 위치 계산을 위한 상수
enum CGCircleGaugeFloat: CGFloat {
    case bottom = 0.525 // 배터리 0 퍼센트
    case top = 0.975 // 배터리 100 퍼센트
    
    func add(for percent: Double) -> CGFloat {
        self.rawValue + ((CGCircleGaugeFloat.top.rawValue - CGCircleGaugeFloat.bottom.rawValue) / 100.0) * percent
    }
}
