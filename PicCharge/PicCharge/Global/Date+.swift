//
//  Date+.swift
//  PicCharge
//
//  Created by 남유성 on 5/19/24.
//

import Foundation

extension Date {
    func timeIntervalKRString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour]
        formatter.maximumUnitCount = 2
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        
        guard let formattedString = formatter.string(from: timeInterval) else {
            return "N/A"
        }
        
        let koreanString = formattedString
            .replacingOccurrences(of: "days", with: "일")
            .replacingOccurrences(of: "day", with: "일")
            .replacingOccurrences(of: "hours", with: "시간")
            .replacingOccurrences(of: "hour", with: "시간")
            .replacingOccurrences(of: ",", with: "")
        
        return koreanString
    }
}
