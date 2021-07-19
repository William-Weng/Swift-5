//
//  Utility.swift
//  NFC_CheckIn
//
//  Created by William.Weng on 2020/2/17.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

// UserDefault的key
enum UserInfo: String {
    case identity = "identity"
    case username = "username"
    case metting = "metting"
}

// Firebase的資料庫路徑
enum DatabasePath: String {
    case `default` = "@NFC"
    case checkIn = "@NFC/CheckIn"
    case nfcTag = "@NFC/NFC_Tag"
    case meetingInformation = "@NFC/MeetingInformation"
}

/// 自定義的Print
public func wwPrint<T>(_ msg: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    Swift.print("🚩 \((file as NSString).lastPathComponent)：\(line) - \(method) \n\t ✅ \(msg)")
    #endif
}

// MARK: - 工具
final class Utility: NSObject {
    
    /// 提示AlertController (OK)
    static func promptAlertController(withTitle title: String, message: String, okAction: @escaping () -> Void) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in okAction() }
        
        alertController.addAction(okAction)
        
        return alertController
    }
    
    /// 開啟網頁
    static func gotoURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    /// https://www.hangge.com/blog/cache/detail_1583.html
    static func urlEncoded(_ urlString: String) -> String? {
        let encodeUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodeUrlString
    }
}
