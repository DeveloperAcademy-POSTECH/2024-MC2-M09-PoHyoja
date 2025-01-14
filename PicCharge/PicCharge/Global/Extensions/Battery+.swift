//
//  Battery+.swift
//  PicCharge
//
//  Created by 김도현 on 1/8/25.
//

import Foundation

struct BatteryCalculator {
    private enum TimeUnit {
        case seconds(Int)
        case minutes(Int)
        case hours(Int)
        case days(Int)
        
        var inSeconds: Double {
            switch self {
            case .seconds(let value):
                return Double(value)
            case .minutes(let value):
                return Double(value * 60)
            case .hours(let value):
                return Double(value * 60 * 60)
            case .days(let value):
                return Double(value * 24 * 60 * 60)
            }
        }
    }
    
    static func calculateBatteryPercentage(
        lastUploadDate: Date,
        uploadCycle: Int,
        currentTime: Date = Date()
    ) -> Double {
        let timeElapsed = currentTime.timeIntervalSince(lastUploadDate)
        let uploadCycleSeconds = TimeUnit.days(3).inSeconds
        
        return max(100.0 - (100 * timeElapsed / uploadCycleSeconds), 0.0)
    }
}

