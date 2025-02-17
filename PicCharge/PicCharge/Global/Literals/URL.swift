//
//  URL.swift
//  PicCharge
//
//  Created by 남유성 on 1/13/25.
//

import Foundation

enum AppInfo {
    static let AppId = 6739777922
    static let email = "pohyoja@gmail.com"
}

enum AppURL {
    static let emailSupport = "mailto:\(AppInfo.email)?subject=\("픽챠 문의하기".toUrlPathable())"
    static let appReview = "https://apps.apple.com/app/id\(AppInfo.AppId)?action=write-review"
    static let privacyPolicy = "https://sites.google.com/view/piccharge-privacy/홈"
    static let termsOfService = "https://sites.google.com/view/piccharge-service-policy/홈"
}

extension String {
    func toUrlPathable() -> String {
        self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
}
