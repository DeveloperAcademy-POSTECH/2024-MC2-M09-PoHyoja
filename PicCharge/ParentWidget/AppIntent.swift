//
//  AppIntent.swift
//  ParentWidget
//
//  Created by 김도현 on 5/19/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
}

struct GoToChargeIntent: AppIntent {
    static var title: LocalizedStringResource = "충전하러가기"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
