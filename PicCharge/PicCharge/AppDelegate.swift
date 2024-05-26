//
//  AppDelegate.swift
//  PicCharge
//
//  Created by 남유성 on 5/26/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import WidgetKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: any Error
    ) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 여기서 사용자 데이터 처리 로직을 구현합니다.
        // 예: 새로운 데이터를 서버에서 가져와 로컬 데이터베이스에 저장
        print("didReceive: userInfo: ", userInfo)
        
        let urlString = "https://picsum.photos/id/\(200 + (Int.random(in: 0..<100)))/200/300"

        // MARK: - UserDefault에 저장
        UserDefaults.shared.set(urlString, forKey: "urlString")
        print(UserDefaults.shared.string(forKey: "urlString"))

        // MARK: - 타임라인 리로드
        WidgetCenter.shared.reloadAllTimelines()
        print("3")
        
        
        
        completionHandler(.newData)
    }
}



extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        print("Firebase registration token: \(String(describing: fcmToken))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions
    ) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        print("UserInfo: ", userInfo)
        
        let urlString = "https://picsum.photos/id/\(200 + (Int.random(in: 0..<100)))/200/300"

        // MARK: - UserDefault에 저장
        UserDefaults.shared.set(urlString, forKey: "urlString")
        print(UserDefaults.shared.string(forKey: "urlString"))

        // MARK: - 타임라인 리로드
        WidgetCenter.shared.reloadAllTimelines()
        print("1")
        
        completionHandler([.banner])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        let userInfo = response.notification.request.content.userInfo
        print("didReceive: userInfo: ", userInfo)
        
        let urlString = "https://picsum.photos/id/\(200 + (Int.random(in: 0..<100)))/200/300"

        // MARK: - UserDefault에 저장
        UserDefaults.shared.set(urlString, forKey: "urlString")
        print(UserDefaults.shared.string(forKey: "urlString"))

        // MARK: - 타임라인 리로드
        WidgetCenter.shared.reloadAllTimelines()
        print("2")
        
        completionHandler()
    }
}

