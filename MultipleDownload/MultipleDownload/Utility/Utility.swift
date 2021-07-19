//
//  Utility.swift
//  MultipleDownload
//
//  Created by William.Weng on 2020/8/25.
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
}

// MARK: - enum
extension Utility {
    /// 自訂錯誤
    enum MyError: Error, LocalizedError {
        
        var errorDescription: String {
            switch self {
            case .unknown: return "未知錯誤"
            case .urlFormat: return "URL格式錯誤"
            case .callTelephone: return "播打電話錯誤"
            case .openSettingsPage: return "打開APP設定頁錯誤"
            case .geocodeLocation: return "地理編碼錯誤"
            case .urlDownload: return "URL下載錯誤"
            case .isEmptyData: return "資料是空的"
            }
        }
        
        case unknown
        case urlFormat
        case callTelephone
        case openSettingsPage
        case geocodeLocation
        case urlDownload
        case isEmptyData
    }
    
    /// [網頁檔案類型的MimeType](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types)
    enum MimeType {
        
        var mimeType: String { return mimeTypeMaker() }
        var fileExtension: String { return fileExtensionMaker() }
        
        case jpeg(compressionQuality: CGFloat)
        case png
        case bin
        case gif
        case txt
        case pdf
        case webp
        case bmp
        case heic
        case avif
        case svg

        /// 產生副檔名 (jpg / png / gif)
        private func fileExtensionMaker() -> String {
            switch self {
            case .bin: return ".bin"
            case .pdf: return ".pdf"
            case .txt: return ".txt"
            case .jpeg: return ".jpeg"
            case .png: return ".png"
            case .gif: return ".gif"
            case .webp: return ".webp"
            case .bmp:  return ".bmp"
            case .heic: return ".heic"
            case .avif: return "avif"
            case .svg: return ".svg"
            }
        }

        /// 產生MimeType (image/jpeg)
        private func mimeTypeMaker() -> String {
            switch self {
            case .bin: return "application/octet-stream"
            case .pdf: return "application/pdf"
            case .txt: return "text/plain"
            case .jpeg: return "image/jpeg"
            case .png: return "image/png"
            case .gif: return "image/gif"
            case .webp: return "image/webp"
            case .bmp: return "image/bmp"
            case .heic: return "image/heic"
            case .avif: return "image/avif"
            case .svg: return "image/svg+xml"
            }
        }
    }
}

// MARK: - 圖片相關 (UIImage)
extension Utility {
    /// UIImage => Data
    func imageDataMaker(_ image: UIImage, mimeType: Utility.MimeType = .png) -> Data? {
        
        switch mimeType {
        case .jpeg(let compressionQuality): return image.jpegData(compressionQuality: compressionQuality)
        case .png: return image.pngData()
        default: return nil
        }
    }
}

// MARK: - 通知相關
extension Utility {
    
    /// String => Notification.Name
    func notificationNameMaker(_ name: String) -> Notification.Name {
         return Notification.Name(rawValue: name)
    }

    /// 註冊通知
    func registeredNotification(name: Notification.Name, queue: OperationQueue = .main, object: Any? = nil, handler: @escaping ((Notification) -> Void)) {
        
        NotificationCenter.default.addObserver(forName: name, object: object, queue: queue) { (notification) in
            handler(notification)
        }
    }
    
    /// 發射通知
    func postNotification(name: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.post(name: name, object: object)
    }
    
    /// 移除通知
    func removelNotification(observer: Any, name: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.removeObserver(observer, name: name, object: object)
    }
}

// MARK: - URL Scheme
extension Utility {

    /// URL編碼 (是在哈囉 => %E6%98%AF%E5%9C%A8%E5%93%88%E5%9B%89)
    func encodingURL(string: String, characterSet: CharacterSet = .urlQueryAllowed) -> String? {
        return string.addingPercentEncoding(withAllowedCharacters: characterSet)
    }

    /// URL解碼 (%E6%98%AF%E5%9C%A8%E5%93%88%E5%9B%89 => 是在哈囉)
    func decodingURL(string: String) -> String? {
        return string.removingPercentEncoding
    }
    
    /// Dictionary => JSON Data (["name":"William"] => {"name":"William"} => 7b2268747470223a2022626f6479227d)
    func jsonSerialization(with parameters: [String: Any]) -> Data? {
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        return data
    }
    
    /// Data => JSON (7b2268747470223a2022626f6479227d => {"http": "body"})
    func jsonSerialization(with data: Data?) -> Any? {

        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        else {
            return nil
        }

        return json
    }

    /// String => Data
    func dataMaker(string: String, encoding: String.Encoding = .utf8, isLossyConversion: Bool = true) -> Data? {
        let data = string.data(using: encoding, allowLossyConversion: isLossyConversion)
        return data
    }
}
