//
//  Extension+.swift
//  MyEnglish
//
//  Created by William.Weng on 2021/1/13.
//
import UIKit
import WebKit
import AVFoundation

// MARK: - Collection (class function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - Int (class function)
extension Int {
    
    /// 數字位數變換
    /// - 1 => 001
    /// - Parameter count: 需要的位數
    /// - Returns: String
    func _repeatString(count: UInt = 2) -> String {

        let formatType = "%\(String(repeating: "0", count: Int(count)))\(count)d"
        let formatString = String(format: formatType, self)

        return "\(formatString)"
    }
}

// MARK: - Locale (static function)
extension Locale {
    
    /// 取得首選語系 (第一個語系)
    /// - 設定 -> 一般 -> 語言與地區 -> 偏好的語言順序 (zh-Hant-TW / [語系-分支-地區])
    /// - Returns: [語系辨識碼](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html)
    static func _preferredLanguage() -> String? {
        guard let language = Locale.preferredLanguages.first else { return nil }
        return language
    }
    
    /// 把完整的語系編碼分類
    /// - zh-Hant-TW => [語系-分支-地區]
    /// - Parameter language: 完整的語系文字
    /// - Returns: Utility.LanguageInfomation?
    static func _preferredLanguageInfomation(_ language: String? = Locale.preferredLanguages.first) -> Utility.LanguageInfomation? {
        
        guard let preferredLanguage = language,
              let languageInfos = Optional.some(preferredLanguage.split(separator: "-")),
              languageInfos.count > 0
        else {
            return nil
        }
        
        var info: Utility.LanguageInfomation = (nil, nil, nil)
        
        switch languageInfos.count {
        case 1: info.code = languageInfos.first
        case 2: info.code = languageInfos.first; info.region = languageInfos.last
        case 3: info.code = languageInfos.first; info.region = languageInfos.last; info.script = languageInfos[safe: 1]
        default: break
        }
        
        return info
    }
}

// MARK: - URLRequest (class function)
extension URLRequest {
    
    /// enum版的.setValue(_,forHTTPHeaderField:_)
    /// - Parameters:
    ///   - value: 要設定的值
    ///   - field: 要設定的欄位
    mutating func _setValue(_ value: Utility.ContentType, forHTTPHeaderField field: Utility.HTTPHeaderField) {
        self.setValue("\(value)", forHTTPHeaderField: field.rawValue)
    }
}

// MARK: - UIColr (init function)
extension UIColor {
    
    /// UIColor(red: 255, green: 255, blue: 255, alpha: 255)
    /// - Parameters:
    ///   - red: 紅色 => 0~255
    ///   - green: 綠色 => 0~255
    ///   - blue: 藍色 => 0~255
    ///   - alpha: 透明度 => 0~255
    convenience init(red: Int, green: Int, blue: Int, alpha: Int) { self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0) }
    
    /// UIColor(red: 255, green: 255, blue: 255)
    /// - Parameters:
    ///   - red: 紅色 => 0~255
    ///   - green: 綠色 => 0~255
    ///   - blue: 藍色 => 0~255
    convenience init(red: Int, green: Int, blue: Int) { self.init(red: red, green: green, blue: blue, alpha: 255) }
    
    /// UIColor(rgb: 0xFFFFFF)
    /// - Parameter rgb: 顏色色碼的16進位值數字
    convenience init(rgb: Int) { self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF) }
    
    /// UIColor(rgba: 0xFFFFFFFF)
    /// - Parameter rgba: 顏色的16進位值數字
    convenience init(rgba: Int) { self.init(red: (rgba >> 24) & 0xFF, green: (rgba >> 16) & 0xFF, blue: (rgba >> 8) & 0xFF, alpha: (rgba) & 0xFF) }
    
    /// UIColor(rgb: #FFFFFF)
    /// - Parameter rgb: 顏色的16進位值字串
    convenience init(rgb: String) {
        
        let ruleRGB = "^#[0-9A-Fa-f]{6}$"
        let predicateRGB = NSPredicate(format: "SELF MATCHES %@", ruleRGB)
        
        guard predicateRGB.evaluate(with: rgb),
              let string = rgb.split(separator: "#").last,
              let number = Int.init(string, radix: 16)
        else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0); return
        }
        
        self.init(rgb: number)
    }
    
    /// UIColor(rgba: #FFFFFFFF)
    /// - Parameter rgba: 顏色的16進位值字串
    convenience init(rgba: String) {
        
        let ruleRGBA = "^#[0-9A-Fa-f]{8}$"
        let predicateRGBA = NSPredicate(format: "SELF MATCHES %@", ruleRGBA)
        
        guard predicateRGBA.evaluate(with: rgba),
              let string = rgba.split(separator: "#").last,
              let number = Int.init(string, radix: 16)
        else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0); return
        }
        
        self.init(rgba: number)
    }
}

// MARK: - Data
extension Data {
        
    /// BIG5字串Data => UTF8字串
    /// - Parameter stringEncodings: CoreFoundation字元編碼
    /// - Returns: String?
    func _utf8String(with stringEncodings: CFStringEncodings = .big5) -> String? {
        let encoding = String._encoding(with: stringEncodings)
        return String(data: self, encoding: encoding)
    }
    
    /// Data => 字串
    /// - Parameter encoding: 字元編碼
    /// - Returns: String?
    func _string(using encoding: String.Encoding = .utf8) -> String? {
        return String(bytes: self, encoding: encoding)
    }
    
    /// Data => JSON
    /// - 7b2268747470223a2022626f6479227d => {"http": "body"}
    /// - Returns: Any?
    func _jsonSerialization(options: JSONSerialization.ReadingOptions = .allowFragments) -> Any? {
        guard let json = try? JSONSerialization.jsonObject(with: self, options: options) else { return nil }
        return json
    }
}

// MARK: - String
extension String {

    /// 編碼轉換
    /// - CFStringEncodings => String.Encoding
    /// - Parameter stringEncodings: CoreFoundation字元編碼
    /// - Returns: String.Encoding
    static func _encoding(with cfStringEncodings: CFStringEncodings) -> String.Encoding {

        let encoding = CFStringEncoding(cfStringEncodings.rawValue)
        let encodingRawValue = CFStringConvertEncodingToNSStringEncoding(encoding)
        
        return String.Encoding(rawValue: encodingRawValue)
    }
    
    /// URL編碼 (百分比)
    /// - 是在哈囉 => %E6%98%AF%E5%9C%A8%E5%93%88%E5%9B%89
    /// - Parameter characterSet: 字元的判斷方式
    /// - Returns: String?
    func _encodingURL(characterSet: CharacterSet = .urlQueryAllowed) -> String? { return addingPercentEncoding(withAllowedCharacters: characterSet) }
    
    /// [國家地區代碼](https://zh.wikipedia.org/wiki/國家地區代碼)
    /// - [顏文字：AA => 🇦🇦 / TW => 🇹🇼](https://lets-emoji.com/)
    /// - Returns: String
    func _flagEmoji() -> String {
        
        let characterA: (ascii: String, unicode: UInt32, error: String) = ("A", 0x1F1E6, "？")
        var unicodeString = ""

        for scalar in unicodeScalars {
            
            guard let asciiA = characterA.ascii.unicodeScalars.first,
                  let unicodeWord = UnicodeScalar(characterA.unicode + scalar.value - asciiA.value)
            else {
                unicodeString += characterA.error.description; continue
            }

            let wordRange = Int(unicodeWord.value) - Int(characterA.unicode) + 1
            
            switch wordRange {
            case 1...26: unicodeString += "\(unicodeWord)"
            default: unicodeString += characterA.error
            }
        }
        
        return unicodeString
    }
    
    /// 字串 => 資料
    /// - Parameters:
    ///   - encoding: 字元編碼
    ///   - isLossyConversion: 失真轉換
    /// - Returns: Data?
    func _data(using encoding: String.Encoding = .utf8, isLossyConversion: Bool = true) -> Data? {
        let data = self.data(using: encoding, allowLossyConversion: isLossyConversion)
        return data
    }
}

// MARK: - WKWebView
extension WKWebView {
    
    /// 產生WKWebView (WKNavigationDelegate & WKUIDelegate)
    /// - Parameters:
    ///   - delegate: WKNavigationDelegate & WKUIDelegate
    ///   - frame: WKWebView的大小
    ///   - configuration: WKWebViewConfiguration
    /// - Returns: WKWebView
    static func _build(delegate: (WKNavigationDelegate & WKUIDelegate)?, frame: CGRect, configuration: WKWebViewConfiguration = WKWebViewConfiguration()) -> WKWebView {
        
        let webView = WKWebView(frame: frame, configuration: configuration)
        
        webView.backgroundColor = .white
        webView.navigationDelegate = delegate
        webView.uiDelegate = delegate
        
        return webView
    }
}

// MARK: - URL (static function)
extension URL {
    
    /// 將URL標準化
    /// - 是在哈囉 => %E6%98%AF%E5%9C%A8%E5%93%88%E5%9B%89
    /// - Parameters:
    ///   - string: url字串
    ///   - characterSet: 字元的判斷方式
    /// - Returns: URL?
    static func _standardization(string: String, characterSet: CharacterSet = .urlQueryAllowed) -> URL? {
        
        var url: URL?
        url = URL(string: string)
        
        guard url == nil,
              let encodeString = string._encodingURL()
        else {
            return url
        }

        return URL(string: encodeString)
    }
}

// MARK: - AVSpeechSynthesizer (static function)
extension AVSpeechSynthesizer {
    
    /// 產生AVSpeechSynthesizer
    /// - Parameter delegate: AVSpeechSynthesizerDelegate
    static func _build(delegate: AVSpeechSynthesizerDelegate? ) -> AVSpeechSynthesizer {
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = delegate
        
        return synthesizer
    }
}

// MARK: - AVSpeechSynthesizer (class function)
extension AVSpeechSynthesizer {
    
    /// 讀出文字
    /// - Parameters:
    ///   - string: 要讀出的文字
    ///   - voice: 使用的聲音語言
    func _speak(string: String, voice: Utility.VoiceCode = .english) {
        
        let utterance = AVSpeechUtterance._build(string: string, voice: voice)
        self.speak(utterance)
    }
}

// MARK: - AVSpeechUtterance (static function)
extension AVSpeechUtterance {
    
    /// 產生AVSpeechUtterance
    /// - Parameters:
    ///   - string: 要讀的文字
    ///   - voice: 使用的聲音語言
    /// - Returns: AVSpeechUtterance
    static func _build(string: String, voice: Utility.VoiceCode = .english) -> AVSpeechUtterance {

        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: voice.code())

        return utterance
    }
}


// MARK: - UIAlertController (static function)
extension UIAlertController {
    
    /// AlertController基本型 (僅標題文字)
    /// - Parameters:
    ///   - title: 標題文字
    ///   - message: 內容訊息
    ///   - preferredStyle: 彈出的型式
    /// - Returns: UIAlertController
    static func _build(with title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        return alertController
    }
    
    /// 選擇用的AlertController (OK / Option1 / Option2)
    /// - Parameters:
    ///   - title: 標題文字
    ///   - message: 內容訊息
    ///   - preferredStyle: 彈出的型式
    ///   - actions: 按下OK的動作
    /// - Returns: UIAlertController
    static func _optionAlertController(with title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, actions: [Utility.AlertActionInfomation]) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

        actions.forEach { (info) in
            let action = UIAlertAction(title: info.title, style: info.style) { (_) in if let handler = info.handler { handler() } }
            alertController.addAction(action)
        }
        
        return alertController
    }
}
