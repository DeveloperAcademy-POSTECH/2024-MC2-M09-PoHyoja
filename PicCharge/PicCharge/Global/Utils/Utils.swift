//
//  Utils.swift
//  PicCharge
//
//  Created by 남유성 on 1/13/25.
//

import Foundation

enum Utils {
    static func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    static func getBuildVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    }
}
