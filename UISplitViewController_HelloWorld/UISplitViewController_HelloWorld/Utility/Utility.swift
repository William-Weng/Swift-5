import UIKit

// MARK: - 自定義的Print
public func wwPrint<T>(_ msg: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        Swift.print("🚩 \((file as NSString).lastPathComponent)：\(line) - \(method) \n\t ✅ \(msg)")
    #endif
}

// MARK: - Utility
final class Utility: NSObject {
    typealias ScreenBoundsInfomation = (width: CGFloat, height: CGFloat, scale: CGFloat)  // iPhone的裝置螢幕大小 (寬/高/比例)
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
            case .openURL: return "打開URL錯誤"
            case .openSettingsPage: return "打開APP設定頁錯誤"
            case .geocodeLocation: return "地理編碼錯誤"
            case .urlDownload: return "URL下載錯誤"
            case .isEmpty: return "資料是空的"
            }
        }
        
        case unknown
        case urlFormat
        case callTelephone
        case openURL
        case openSettingsPage
        case geocodeLocation
        case urlDownload
        case isEmpty
    }
}


// MARK: - UtilitySystem
final class UtilitySystem: NSObject {}

// MARK: - typealias
extension UtilitySystem {
    
    typealias KeyboardInfomation = (duration: Double, curve: UInt, frame: CGRect)                           // 取得系統鍵盤的相關資訊
    typealias APNSInfomation = (alert: String?, badge: Int?, sound: String?, payload: Any?)                 // 推播的JSON檔 => APNSInfomation
    typealias ScreenBoundsInfomation = (width: CGFloat, height: CGFloat, scale: CGFloat)                    // iPhone的裝置螢幕大小 (寬/高/比例)
}
