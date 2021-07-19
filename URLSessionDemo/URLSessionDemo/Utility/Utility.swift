//
//  Utility.swift
//  URLSessionDemo
//
//  Created by William.Weng on 2020/8/11.
//  Copyright © 2020 William.Weng. All rights reserved.
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
    
    /// 自訂錯誤
    enum MyError: Error, LocalizedError {
        
        var errorDescription: String {
            switch self {
            case .unknown: return "未知錯誤"
            case .urlFormat: return "URL格式錯誤"
            case .urlDownload: return "URL下載錯誤"
            }
        }

        case unknown
        case urlFormat
        case urlDownload
    }
    
    /// [網頁檔案類型的MimeType](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types)
    enum MimeType: String {
        
        var fileExtension: String { return fileExtensionMaker() }
        
        case jpeg = "image/jpeg"
        case png = "image/png"

        /// 產生副檔名 (jpg / png)
        private func fileExtensionMaker() -> String {
            switch self {
            case .jpeg: return "jpg"
            case .png: return "png"
            }
        }
    }
}

// MARK: - 小工具
extension Utility {
    
    /// Data => JSON (7b2268747470223a2022626f6479227d => {"http": "body"})
    func jsonSerialization(with data: Data?) -> Any? {

        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        else {
            return nil
        }

        return json
    }

    /// Dictionary => JSON Data (["name":"William"] => {"name":"William"} => 7b2268747470223a2022626f6479227d)
    func jsonSerialization(with parameters: [String: Any]) -> Data? {
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        return data
    }

    /// String => Data
    func dataMaker(string: String, encoding: String.Encoding = .utf8, isLossyConversion: Bool = true) -> Data? {
        let data = string.data(using: encoding, allowLossyConversion: isLossyConversion)
        return data
    }
    
    /// URL編碼 (是在哈囉 => %E6%98%AF%E5%9C%A8%E5%93%88%E5%9B%89)
    func encodingURL(string: String, characterSet: CharacterSet = .urlQueryAllowed) -> String? {
        return string.addingPercentEncoding(withAllowedCharacters: characterSet)
    }

    /// URL解碼 (%E6%98%AF%E5%9C%A8%E5%93%88%E5%9B%89 => 是在哈囉)
    func decodingURL(string: String) -> String? {
        return string.removingPercentEncoding
    }
}
