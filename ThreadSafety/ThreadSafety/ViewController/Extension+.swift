//
//  Extension+.swift
//  ThreadSafety
//
//  Created by William.Weng on 2022/11/2.
//

import UIKit
import WWPrint
import SwiftUI

// MARK: - String (class function)
extension String {
    
    /// 將Markdown文字轉成AttributedString
    /// - Returns: NSAttributedString
    @available(iOS 15, *)
    func _markdownAttributedString() throws -> AttributedString {
        return try AttributedString(markdown: self)
    }
}

// MARK: - NSLock (static function)
extension NSLock {
    
    /// 產生NSLock
    /// - Parameter name: 它的名字
    /// - Returns: NSLock
    static func _build(name: String? = nil) -> NSLock {
        let lock = NSLock()
        lock.name = name
        return lock
    }
    
    /// [仿Objective-C的@synchronized - 互斥鎖](https://blog.csdn.net/LiqunZhang/article/details/115465062)
    /// - Parameters:
    ///   - token: [當lock的Key](https://awesome-tips.github.io/2019/01/01/Swift-中实现-synchronized.html)
    ///   - action: 要保護的數值
    /// - Returns: T
    static func _synchronized<T>(token: AnyObject, action: () -> T) -> T {
        
        objc_sync_enter(token)
        defer { objc_sync_exit(token) }

        let result = action()
        return result
    }
    
    /// [仿Objective-C的@synchronized => try-catch版本](https://www.jianshu.com/p/e37e2c41f6bf)
    /// - Parameters:
    ///   - token: [當lock的Key](https://github.com/jedlewison/SwiftSynchronized)
    ///   - action: 要保護的數值
    /// - Returns: T
    static func _synchronized<T>(token: AnyObject, action: () throws -> T) rethrows -> T {
        
        objc_sync_enter(token)
        defer { objc_sync_exit(token) }
        
        let result = try action()
        return result
    }
}

// MARK: - NSLock (class function)
extension NSLock {
    
    /// [執行緒安全 (防止多線程造成數據不正確)](http://shoshino21.logdown.com/)
    /// - Parameter action: [要保護的數值](https://swift.gg/2018/07/30/friday-qa-2015-02-20-lets-build-synchronized/)
    /// - Returns: T
    func _threadSafety<T>(action: () -> T) -> T {
        
        lock()
        defer { unlock() }
        
        let result = action()
        return result
    }
    
    /// [執行緒安全 (防止多線程造成數據不正確) => try-catch版本](http://shoshino21.logdown.com/posts/7818726)
    /// - Parameter action: 要保護的數值
    /// - Returns: T
    func _threadSafety<T>(action: () throws -> T) rethrows -> T {
        
        lock()
        defer { unlock() }
        
        let result = try action()
        return result
    }
}

// MARK: - Date (Operator Overloading)
extension Date {
    
    /// 日期的加法
    static func +(lhs: Self, rhs: Self) -> TimeInterval {
        return lhs.timeIntervalSince1970 + rhs.timeIntervalSince1970
    }
    
    /// [日期的減法](https://www.appcoda.com.tw/operator-overloading-swift/)
    static func -(lhs: Self, rhs: Self) -> TimeInterval {
        return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
    }
}

// MARK: - Date (static function)
extension Date {
    
    /// 取得現在的時間
    /// - Returns: Date
    static func _now() -> Date { return Date() }
}

// MARK: - Date (class function)
extension Date {
    
    /// 計算經過了多少時間
    /// - Returns: TimeInterval
    func _elapsedTime() -> TimeInterval {
        let timeInterval = Date._now() - self
        return timeInterval
    }
}

// MARK: - NSCondition (static function)
extension NSCondition {
    
    /// [產生NSCondition](https://zhuanlan.zhihu.com/p/395894695)
    /// - Parameter name: [它的名字](https://choujiji.github.io/2019/08/02/iOS中的锁 笔记/)
    /// - Returns: [NSCondition](https://wjerry.com/2018/06/iOS中各种-锁-的理解及应用/)
    static func _build(name: String?) -> NSCondition {
        let condition = NSCondition()
        condition.name = name
        return condition
    }
}

// MARK: - NSCondition (class function)
extension NSCondition {
    
    /// [執行緒安全 (防止多線程造成數據不正確)](https://www.jianshu.com/p/5d20c15ae690)
    /// - Parameters:
    ///   - action: [要執行的動作](https://www.jianshu.com/p/518245356201)
    ///   - condition: 暫停的條件
    /// - Returns: T
    func _threadSafety<T>(action: () -> T, wait condition: () -> Bool) -> T {
        
        lock()
                
        if (condition()) { wait() }
        let result = action()
        
        signal()
        unlock()
        
        return result
    }
    
    /// [執行緒安全 (防止多線程造成數據不正確) => try-catch版本](https://blog.csdn.net/sinat_31177681/article/details/116269161)
    /// - Parameters:
    ///   - action: [要執行的動作](https://juejin.cn/post/6844904146932334600)
    ///   - condition: 暫停的條件
    /// - Returns: T
    func _threadSafety<T>(action: () throws -> T, wait condition: () -> Bool) rethrows -> T {
        
        lock()
                
        if (condition()) { wait() }
        let result = try action()
        
        signal()
        unlock()
        
        return result
    }
}

@propertyWrapper
struct Atomic<T> {
    
    private let lock: NSLock
    private var value: T
    
    var wrappedValue: T {
        get { return lock._threadSafety() { value } }
        set { lock._threadSafety() { value = newValue } }
    }
    
    init(wrappedValue value: T) {
        self.value = value
        lock = NSLock._build(name: "\(Date().timeIntervalSince1970)")
    }
    
    /// [要執行的變異動作](https://www.vadimbulavin.com/swift-atomic-properties-with-property-wrappers/)
    /// - Parameter mutation: (inout T) -> Void
    mutating func action(_ mutation: (inout T) -> Void) {
        return lock._threadSafety() { mutation(&value) }
    }
}

// MARK: - UIHostingController
extension UIHostingController {
    
    /// 將SwiftUI -> UIKit的ViewController
    /// - Parameter rootView: Content
    /// - Returns: UIHostingController<Content>
    static func _build(rootView: Content) -> UIHostingController<Content> {
        let viewController = UIHostingController(rootView: rootView)
        return viewController
    }
}
