//
//  Color+.swift
//  PicCharge
//
//  Created by 남유성 on 5/19/24.
//

import SwiftUI

extension Color {
    static func wgBattery(percent: Double) -> Color {
        switch percent {
        case 0..<10: return .wgBattery10
        case 10..<20: return .wgBattery20
        case 20..<30: return .wgBattery30
        case 30..<40: return .wgBattery40
        case 40..<50: return .wgBattery50
        case 50..<60: return .wgBattery60
        case 60..<70: return .wgBattery70
        case 70..<80: return .wgBattery80
        case 80..<90: return .wgBattery90
        default: return .wgBattery100
        }
    }
    
    static func battery(percent: Double) -> Color {
        switch percent {
        case 0..<10: return .battery10
        case 10..<20: return .battery20
        case 20..<30: return .battery30
        case 30..<40: return .battery40
        case 40..<50: return .battery50
        case 50..<60: return .battery60
        case 60..<70: return .battery70
        case 70..<80: return .battery80
        case 80..<90: return .battery90
        default: return .battery100
        }
    }
}
