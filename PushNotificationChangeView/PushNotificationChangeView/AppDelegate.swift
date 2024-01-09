//
//  AppDelegate.swift
//  Example
//
//  Created by William.Weng on 2023/9/11.
//

import UIKit
import WWPrint

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var userInfo: [AnyHashable : Any] = [:] {
        didSet { NotificationCenter.default._post(name: ViewController.notificationName, object: userInfo) }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current()._userNotificationSetting(delegate: self) {
            wwPrint("已授權")
        } rejectedHandler: {
            wwPrint("未授權")
        } deniedHandler: {
            wwPrint("關閉授權")
        } result: { status in
            wwPrint(status)
        }
        
        return true
    }
}

// MARK: - 推播相關
extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        wwPrint(deviceToken)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        wwPrint("收到推播 => \(userInfo)")
        completionHandler([.badge, .sound, .banner, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.userInfo = response.notification.request.content.userInfo
        wwPrint("點擊推播 => \(userInfo)")
        completionHandler()
    }
}

