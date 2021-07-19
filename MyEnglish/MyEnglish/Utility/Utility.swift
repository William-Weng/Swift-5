//
//  Utility.swift
//  MyEnglish
//
//  Created by William.Weng on 2021/1/13.
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

// MARK: - typealias
extension Utility {
    typealias AlertActionInfomation = (title: String?, style: UIAlertAction.Style, handler: (() -> Void)?)                          // UIAlertController的按鍵相關資訊
    typealias LanguageInfomation = (code: String.SubSequence?, script: String.SubSequence?, region: String.SubSequence?)            // 語言資訊 => [語系-分支-地區]
}

extension Utility {
    
    /// [HTTP標頭欄位](https://zh.wikipedia.org/wiki/HTTP头字段)
    enum HTTPHeaderField: String {
        case acceptRanges = "Accept-Ranges"
        case authorization = "Authorization"
        case contentType = "Content-Type"
        case contentLength = "Content-Length"
        case contentRange = "Content-Range"
        case contentDisposition = "Content-Disposition"
        case date = "Date"
        case lastModified = "Last-Modified"
        case range = "Range"
    }
    
    /// [AVSpeechSynthesisVoice List](https://stackoverflow.com/questions/35492386/how-to-get-a-list-of-all-voices-on-ios-9/43576853)
    enum VoiceCode {
        
        case english
        case japanese
        case korean
        case chinese
        
        func tablename() -> String {
            switch self {
            case .english: return "English"
            case .japanese: return "Japanese"
            case .korean: return "Korean"
            case .chinese: return "Chinese"
            }
        }
        
        /// [AVSpeechSynthesisVoice List](https://stackoverflow.com/questions/35492386/how-to-get-a-list-of-all-voices-on-ios-9/43576853)
        /// - Returns: String
        func code() -> String {
            switch self {
            case .english: return "en-US"
            case .japanese: return "ja-JP"
            case .korean: return "ko-KR"
            case .chinese: return "zh-TW"
            }
        }

        func dictionaryURL(with word: String) -> String {
            
            switch self {
            case .english: return "https://tw.dictionary.search.yahoo.com/search?p=\(word)"
            case .japanese: return "https://dictionary.goo.ne.jp/word/\(word)"
            case .korean: return "https://dic.daum.net/search.do?dic=ch&q=\(word)"
            case .chinese: return "https://cdict.net/?q=\(word)"
            }
        }
    }
    
    /// 過濾的方式 (AND/OR/NOT)
    enum FilterType: String {
        case and = "AND"
        case or = "OR"
        case not = "NOT"
    }

    /// [時間的格式](http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns)
    enum DateFormat: String {
        case full = "yyyy-MM-dd HH:mm:ss ZZZ"
        case long = "yyyy-MM-dd HH:mm:ss"
        case middle = "yyyy-MM-dd HH:mm"
        case short = "yyyy-MM-dd"
    }
    
    /// 自訂錯誤
    enum MyError: Error, LocalizedError {
        
        var errorDescription: String {
            switch self {
            case .unknown: return "未知錯誤"
            case .notUrlFormat: return "URL格式錯誤"
            case .notCallTelephone: return "播打電話錯誤"
            case .notOpenURL: return "打開URL錯誤"
            case .notOpenSettingsPage: return "打開APP設定頁錯誤"
            case .notGeocodeLocation: return "地理編碼錯誤"
            case .notUrlDownload: return "URL下載錯誤"
            case .isEmpty: return "資料是空的"
            case .notSupports: return "該手機不支援"
            case .notEncoding: return "該資料編碼錯誤"
            }
        }

        case unknown
        case isEmpty
        case notUrlFormat
        case notGeocodeLocation
        case notUrlDownload
        case notCallTelephone
        case notEncoding
        case notOpenURL
        case notOpenSettingsPage
        case notSupports
    }

    /// [HTTP 請求方法](https://developer.mozilla.org/zh-TW/docs/Web/HTTP/Methods)
    enum HttpMethod: String {
        case GET = "GET"
        case HEAD = "HEAD"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
        case CONNECT = "CONNECT"
        case OPTIONS = "OPTIONS"
        case TRACE = "TRACE"
        case PATCH = "PATCH"
    }

    /// [HTTP Content-Type](https://www.runoob.com/http/http-content-type.html) => Content-Type: application/json
    enum ContentType: CustomStringConvertible {
        
        var description: String { return toString() }
        
        case json
        case formUrlEncoded
        case formData
        case bearer(forKey: String)
        
        func toString() -> String {
            
            switch self {
            case .json: return "application/json"
            case .formUrlEncoded: return "application/x-www-form-urlencoded"
            case .formData: return "multipart/form-data"
            case .bearer(forKey: let key): return "Bearer \(key)"
            }
        }
    }
}

