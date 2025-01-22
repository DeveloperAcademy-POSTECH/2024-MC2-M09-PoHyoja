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
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: UserEntity.self, PhotoEntity.self)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppNavigationView()
                .injectDIContainer()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
