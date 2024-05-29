//
//  Int+.swift
//  PicCharge
//
//  Created by 남유성 on 5/29/24.
//

import Foundation

extension Int {
    func toKRMinuteAndSeconds() -> String {
        let minutes = Int(self / 60)
        let seconds = Int(self % 60)
        let minutesKR = minutes > 0 ? "\(minutes)분" : ""
        let secondsKR = seconds > 0 ? "\(seconds)초" : ""
        
        if minutes > 0 {
            return "\(minutesKR)"
        } else {
            return "\(secondsKR)"
        }
    }
}
