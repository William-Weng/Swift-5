//
//  Utility.swift
//  HelloMediaPlayer
//
//  Created by William.Weng on 2021/5/4.
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
