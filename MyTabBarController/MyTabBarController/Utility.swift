//
//  Utility.swift
//  MyTabBarController
//
//  Created by William.Weng on 2021/6/7.
//

import UIKit

// MARK: - 自定義的Print
public func wwPrint<T>(_ msg: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        Swift.print("🚩 \((file as NSString).lastPathComponent)：\(line) - \(method) \n\t ✅ \(msg)")
    #endif
}

// MARK: - Utility (單例)
final class Utility: NSObject {
    
    static let shared = Utility()
    private override init() {}
}

// MARK: - enum
extension Utility {
    
    /// NotificationName
    enum NotificationName {
        
        /// 顯示真實的值
        var value: Notification.Name { return notificationName() }
        
        case _tabbarStackViews                  // 加上自定義的TabbarView (自定義)
        case _tabbarDidSelected                 // 自定義的TabbarView被按了 (自定義)
        case _firstViewControllerDidLoad        // 第一個ViewController載入了 (自定義)

        /// 顯示真實的值 => Notification.Name
        func notificationName() -> Notification.Name {
            
            switch self {
            case ._tabbarStackViews: return Notification._name("_tabbarStackViews")
            case ._tabbarDidSelected: return Notification._name("_tabbarDidSelected")
            case ._firstViewControllerDidLoad: return Notification._name("_firstViewControllerDidLoad")
            }
        }
    }
}
