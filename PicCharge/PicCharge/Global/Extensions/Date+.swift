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
            .replacingOccurrences(of: " days", with: "일")
            .replacingOccurrences(of: " day", with: "일")
            .replacingOccurrences(of: " hours", with: "시간")
            .replacingOccurrences(of: " hour", with: "시간")
            .replacingOccurrences(of: ",", with: "")
        
        return koreanString
    }
    
    func timeIntervalKRStringSeconds() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.minute, .second]
        formatter.maximumUnitCount = 2
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        
        guard let formattedString = formatter.string(from: timeInterval) else {
            return "N/A"
        }
        
        let koreanString = formattedString
            .replacingOccurrences(of: " minutes", with: "분")
            .replacingOccurrences(of: " minute", with: "분")
            .replacingOccurrences(of: " seconds", with: "초")
            .replacingOccurrences(of: " second", with: "초")
            .replacingOccurrences(of: ",", with: "")
        
        return koreanString
    }
    
    func toKR() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 M월 d일"
        
        return formatter.string(from: self)
    }
}
