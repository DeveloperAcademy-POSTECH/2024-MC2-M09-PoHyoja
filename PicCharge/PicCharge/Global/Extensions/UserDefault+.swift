//
//  UserDefault+.swift
//  PicCharge
//
//  Created by 김도현 on 5/20/24.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let bundle = Bundle.main.bundleIdentifier
        let appGroupId = "group." + (bundle ?? "com.pohyoja.PicCharge")
        return UserDefaults(suiteName: appGroupId)!
    }
}
