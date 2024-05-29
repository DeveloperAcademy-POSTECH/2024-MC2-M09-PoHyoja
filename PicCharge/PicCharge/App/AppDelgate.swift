//
//  AppDelgate.swift
//  PicCharge
//
//  Created by 남유성 on 5/27/24.
//

import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
    
        FirebaseApp.configure()
        return true
    }
}
