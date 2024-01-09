//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2023/9/11.
//

import UIKit

// MARK: - Data (function)
extension Data {
    
    /// [Data => 16進位文字](https://zh.wikipedia.org/zh-tw/十六进制)
    /// - %02x - 推播Token常用
    /// - Returns: String
    func _hexString() -> String {
        let hexString = reduce("") { return $0 + String(format: "%02x", $1) }
        return hexString
    }
}

// MARK: - UIViewController (function)
extension UIViewController {
    
    /// [設定UIViewController透明背景 (當Alert用)](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-view-controller-實現-ios-app-的彈出視窗-d1c78563bcde)
    /// - Parameters:
    ///   - backgroundColor: 背景色
    ///   - transitionStyle: 轉場的Style
    ///   - presentationStyle: 彈出的Style
    func _modalStyle(_ backgroundColor: UIColor = .white, transitionStyle: UIModalTransitionStyle = .coverVertical, presentationStyle: UIModalPresentationStyle = .currentContext) {
        self.view.backgroundColor = backgroundColor
        self.modalPresentationStyle = presentationStyle
        self.modalTransitionStyle = transitionStyle
    }
}

// MARK: - UNUserNotificationCenter (static function)
extension UNUserNotificationCenter {
    
    /// 註冊推播 => MainQueue
    /// - application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
    static func _registerForRemoteNotifications() { UIApplication.shared.registerForRemoteNotifications() }
}

// MARK: - UNUserNotificationCenter (function)
extension UNUserNotificationCenter {
    
    /// [推播權限測試](https://www.jianshu.com/p/1320e74e3a7e)
    /// - 使用在登入後才詢問推播
    /// - Parameters:
    ///   - delegate: UNUserNotificationCenterDelegate
    ///   - authorizationOptions: 允許推播通知的類型
    ///   - grantedHandler: 答應的時候要做什麼？
    ///   - rejectedHandler: 沒答應 / 不答應的時候要做什麼？
    ///   - deniedHandler: 被關掉的時候要做什麼？
    ///   - result: 原來的狀態 => (UNAuthorizationStatus) -> Void
    func _userNotificationSetting(delegate: UNUserNotificationCenterDelegate? = nil, authorizationOptions: UNAuthorizationOptions = [.alert, .badge, .sound], grantedHandler: @escaping () -> Void, rejectedHandler: @escaping () -> Void, deniedHandler: @escaping () -> Void, result: @escaping (UNAuthorizationStatus) -> Void) {
        
        self._pushNotificationAuthorization { (authorizationStatus) in
            
            switch (authorizationStatus) {
            case .notDetermined:
                self.requestAuthorization(options: authorizationOptions) { (isGranted, error) in
                    guard isGranted else { rejectedHandler(); return }
                    DispatchQueue.main.async { Self._registerForRemoteNotifications() }
                    grantedHandler()
                }
            case .authorized, .ephemeral, .provisional:
                DispatchQueue.main.async { Self._registerForRemoteNotifications() }
                self.delegate = delegate
            case .denied:
                deniedHandler()
            @unknown default: fatalError()
            }
            
            result(authorizationStatus)
        }
    }
    
    /// 推播的授權狀態
    /// - Parameter result: (UNAuthorizationStatus) -> Void
    func _pushNotificationAuthorization(result: @escaping (UNAuthorizationStatus) -> Void) {

        self._pushNotificationSettings { (settings) in
            result(settings.authorizationStatus)
        }
    }
    
    /// [推播的設定狀態](https://www.jianshu.com/p/61dd9dd431a9)
    func _pushNotificationSettings(result: @escaping (UNNotificationSettings) -> Void) {
        
        self.getNotificationSettings { (settings) in
            result(settings)
        }
    }
}

// MARK: - Notification (static function)
extension Notification {
    
    /// String => Notification.Name
    /// - Parameter name: key的名字
    /// - Returns: Notification.Name
    static func _name(_ name: String) -> Notification.Name { return Notification.Name(rawValue: name) }
}

// MARK: - NotificationCenter (function)
extension NotificationCenter {
    
    /// 註冊通知
    /// - Parameters:
    ///   - name: 要註冊的Notification名稱
    ///   - queue: 執行的序列
    ///   - object: 接收的資料
    ///   - handler: 監聽到後要執行的動作
    func _register(name: String, queue: OperationQueue = .main, object: Any? = nil, handler: @escaping ((Notification) -> Void)) {
        self.addObserver(forName: Notification._name(name), object: object, queue: queue) { (notification) in handler(notification) }
    }
    
    /// 發出通知
    /// - Parameters:
    ///   - name: 要發出的Notification名稱
    ///   - object: 要傳送的資料
    func _post(name: String, object: Any? = nil) { self.post(name: Notification._name(name), object: object) }
        
    /// 移除通知
    /// - Parameters:
    ///   - observer: 要移除的位置
    ///   - name: 要移除的Notification名稱
    ///   - object: 接收的資料
    func _remove(observer: Any, name: String, object: Any? = nil) { self.removeObserver(observer, name: Notification._name(name), object: object) }
}

// MARK: - UINavigationController (function)
extension UINavigationController {
    
    /// 轉至下一頁ViewController => 動畫完成後
    /// - Parameters:
    ///   - viewController: 下一頁UIViewController
    ///   - completion: 動畫完成後的動作
    func _pushViewController(_ viewController: UIViewController, completion: (() -> Void)?) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        pushViewController(viewController, animated: true)
        
        CATransaction.commit()
    }
}
