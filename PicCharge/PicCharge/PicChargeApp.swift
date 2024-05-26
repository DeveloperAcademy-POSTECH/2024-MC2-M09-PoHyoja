//
//  PicChargeApp.swift
//  PicCharge
//
//  Created by 이상현 on 5/16/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftData

@main
struct PicChargeApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var navigationManager = NavigationManager()
    
    var container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: UserForSwiftData.self, PhotoForSwiftData.self)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationManager.path) {
                ContentView()
                    .navigationDestination(for: PathType.self) { path in
                        path.NavigatingView()
                    }
                    .preferredColorScheme(.dark)
            }
        }
        .modelContainer(container)
        .environment(navigationManager)
    }
}
