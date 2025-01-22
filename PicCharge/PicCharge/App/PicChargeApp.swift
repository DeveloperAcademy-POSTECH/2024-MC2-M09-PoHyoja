//
//  PicChargeApp.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI
import SwiftData

@main
struct PicChargeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppNavigationView()
                .injectDIContainer()
                .globalAlert()
                .preferredColorScheme(.dark)
        }
    }
}
