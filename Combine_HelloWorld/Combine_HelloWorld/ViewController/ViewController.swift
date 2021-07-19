//
//  ViewController.swift
//  Combine_HelloWorld
//
//  Created by William.Weng on 2020/9/17.
//  Copyright © 2020 William.Weng. All rights reserved.
//
/// [30 天了解 Swift 的 Combine :: 第 11 屆 iT 邦幫忙鐵人賽](https://ithelp.ithome.com.tw/users/20119945/ironman/2272)
/// [彈珠圖 ‧ RxJS 5 基本原理](https://rxjs-cn.github.io/RxJS-Ultimate-CN/content/marble-diagrams.html)
/// [RxJS Marbles](https://rxmarbles.com/)
/// [從零打造基本版 Combine　認識 Functional Reactive Programming](https://www.appcoda.com.tw/functional-reactive-programming/)
/// [Good Morning, JS functional Programing. :: 2018 iT 邦幫忙鐵人賽](https://ithelp.ithome.com.tw/users/20075633/ironman/1375)
/// [ Good Morning, Functional JS (Day 29, functor 函子) ](https://ithelp.ithome.com.tw/articles/10197535)

import UIKit
import Combine

final class ViewController: UIViewController {
    
    private let urlString = "https://httpbin.org/get"
    private var subscription: Subscription!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // addOfClosure()
        // addOfCombine()
        
        subscription = URLSession.shared._dataTaskPublisher(urlString: urlString).map({ (data) -> String in
            data!._hexString()
        }).map { (hexString) -> Int in
            hexString?.count ?? 0
        }.subscribe { count in
            wwPrint(count)
        }
        
        // subscription.cancel()
    }
}

extension ViewController {
    
    /// 連續加法 => 使用Array (Array的map => Combine的map => 累加的意思)
    func addForArray() -> [Int] {
        
        let array = [1, 2, 3, 4, 5]
        let newArray = array.map { (number) -> Int in return 10 * number }

        return newArray
    }
    
    /// 連續加法 => 使用Closure (巢狀波動拳)
    func addOfClosure(left: Int = 1, right: Int = 2) {
        
        add(left: left, right: right) { (answear1) in
            add(left: answear1, right: right) { (answear2) in
                add(left: answear2, right: right) { (answear) in
                    wwPrint(answear)
                }
            }
        }
    }
    
    /// 連續加法 => 使用Combine (連鎖呼叫)
    func addOfCombine(left: Int = 1, right: Int = 2) {
        
        let _ = Just(left)
            .map { (initVaule) -> Int in add(left: initVaule, right: right) }
            .map { (answear2) -> Int in add(left: answear2, right: right) }
            .map { (answear3) -> Int in add(left: answear3, right: right) }
            .sink { (value) in wwPrint(value) }
    }
}

// MARK: - 小工具 (Closure)
extension ViewController {
    
    private func add(left: Int, right: Int, onComplete: (Int) -> Void) {
        let result = left + right
        onComplete(result)
    }
}

// MARK: - 小工具 (Combine)
extension ViewController {
    
    private func add(left: Int, right: Int) -> Int { return left + right }
}

// MARK: - 自定義的Print
public func wwPrint<T>(_ msg: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        Swift.print("🚩 \((file as NSString).lastPathComponent)：\(line) - \(method) \n\t ✅ \(msg)")
    #endif
}

// MARK: - Data (class function)
extension Data {
    
    /// Data => 16進位文字 (%02x - 推播Token常用)
    func _hexString() -> String {
        let hexString = reduce("") { return $0 + String(format: "%02x", $1) }
        return hexString
    }
}
