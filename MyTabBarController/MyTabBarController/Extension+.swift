//
//  Extension+.swift
//  MyTabBarController
//
//  Created by William.Weng on 2021/6/7.
//

import UIKit

// MARK: - Collection (override class function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - Notification (static function)
extension Notification {
    
    /// String => Notification.Name
    /// - Parameter name: key的名字
    /// - Returns: Notification.Name
    static func _name(_ name: String) -> Notification.Name { return Notification.Name(rawValue: name) }
    
    /// NotificationName => Notification.Name
    /// - Parameter name: key的名字 (enum)
    /// - Returns: Notification.Name
    static func _name(_ name: Utility.NotificationName) -> Notification.Name { return name.value }
}

// MARK: - NotificationCenter (class function)
extension NotificationCenter {
    
    /// 註冊通知
    /// - Parameters:
    ///   - name: 要註冊的Notification名稱
    ///   - queue: 執行的序列
    ///   - object: 接收的資料
    ///   - handler: 監聽到後要執行的動作
    func _register(name: Notification.Name, queue: OperationQueue = .main, object: Any? = nil, handler: @escaping ((Notification) -> Void)) {
        self.addObserver(forName: name, object: object, queue: queue) { (notification) in handler(notification) }
    }
    
    /// 註冊通知
    /// - Parameters:
    ///   - name: 要註冊的Notification名稱
    ///   - queue: 執行的序列
    ///   - object: 接收的資料
    ///   - handler: 監聽到後要執行的動作
    func _register(name: Utility.NotificationName, queue: OperationQueue = .main, object: Any? = nil, handler: @escaping ((Notification) -> Void)) {
        self._register(name: name.value, handler: handler)
    }
    
    /// 發射通知
    /// - Parameters:
    ///   - name: 要發射的Notification名稱
    ///   - object: 要傳送的資料
    func _post(name: Notification.Name, object: Any? = nil) { self.post(name: name, object: object) }

    /// 發射通知
    /// - Parameters:
    ///   - name: 要發射的Notification名稱
    ///   - object: 要傳送的資料
    func _post(name: Utility.NotificationName, object: Any? = nil) { self._post(name: name.value, object: object) }
    
    /// 移除通知
    /// - Parameters:
    ///   - observer: 要移除的位置
    ///   - name: 要移除的Notification名稱
    ///   - object: 接收的資料
    func _remove(observer: Any, name: Notification.Name, object: Any? = nil) { self.removeObserver(observer, name: name, object: object) }
    
    /// 移除通知
    /// - Parameters:
    ///   - observer: 要移除的位置
    ///   - name: 要移除的Notification名稱
    ///   - object: 接收的資料
    func _remove(observer: Any, name: Utility.NotificationName, object: Any? = nil) { self._remove(observer: observer, name: name.value) }
}

// MARK: - UIColr (static function)
extension UIColor {
    
    /// 隨機顏色
    /// - Returns: UIColor
  static func _random() -> UIColor { return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)}
}

// MARK: - UIView (class function)
extension UIView {
    
    /// 設定LayoutConstraint
    /// - Parameter view: 要設定的View
    /// - Returns: Self
    func _constraint(on view: UIView) {

        removeFromSuperview()
        view.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// MARK: - UIStackView (class function)
extension UIStackView {
    
    /// 加上Views
    /// - Parameter views: [UIView]
    func _addArrangedSubviews(_ views: [UIView]) {
        views.forEach { self.addArrangedSubview($0) }
    }
}

