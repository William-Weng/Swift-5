//
//  Utility.swift
//  MyLocation
//
//  Created by William.Weng on 2021/5/31.
//

import CoreLocation

// MARK: - 自定義的Print
public func wwPrint<T>(_ msg: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        Swift.print("🚩 \((file as NSString).lastPathComponent)：\(line) - \(method) \n\t ✅ \(msg)")
    #endif
}

// MARK: - Utility (單例)
final class Utility: NSObject {
    
    static let shared = Utility()
    
    lazy var locationManager = { CLLocationManager._build(delegate: self) }()

    private override init() {}
}

// MARK: - typealias
extension Utility {
    typealias LocationCountryCode = (GPS: String?, SIMs: [String], preferredLanguage: String?, region: String?)                     // 定位位置 => [GPS / SIM卡 / 首選語言 / 區域]
    typealias LanguageInfomation = (code: String.SubSequence?, script: String.SubSequence?, region: String.SubSequence?)            // 語言資訊 => [語系-分支-地區]
    typealias LocationInfomation = (location: CLLocation?, isAvailable: Bool)                                                       // 定位的相關資訊
}

// MARK: - enum
extension Utility {
    
    /// 自訂錯誤
    enum MyError: Error, LocalizedError {
        
        var errorDescription: String { errorMessage() }

        case notGeocodeLocation
        
        /// 顯示錯誤說明
        /// - Returns: String
        private func errorMessage() -> String {
            
            switch self {
            case .notGeocodeLocation: return "地理編碼錯誤"
            }
        }
    }
    
    /// NotificationName
    enum NotificationName {
        
        /// 顯示真實的值
        var value: Notification.Name { return notificationName() }
        
        // 定位服務 (自定義)
        case _locationServices
        
        /// 顯示真實的值 => Notification.Name
        func notificationName() -> Notification.Name {
            
            switch self {
            case ._locationServices: return Notification._name("_locationServices")
            }
        }
    }
}

// MARK: - 定位相關 (CLLocationManager)
extension Utility {
    
    /// LocationManager狀態處理
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - status: CLAuthorizationStatus
    private func locationManagerStatus(_ manager: CLLocationManager, status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways: manager.startUpdatingLocation()
        case .authorizedWhenInUse: manager.startUpdatingLocation()
        case .notDetermined: manager.stopUpdatingLocation()
        case .denied: manager.stopUpdatingLocation()
        case .restricted: manager.stopUpdatingLocation()
        @unknown default: fatalError()
        }
    }
    
    /// 取得該裝置的國家地域碼
    /// - Notification._name(._locationServices)
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - locations: [CLLocation]
    private func countryCode(with manager: CLLocationManager, locations: [CLLocation]) {
        
        var code = CLLocationManager._locationCountryCode()
        
        guard manager._locationInfomation(with: locations).isAvailable,
              let location = manager._locationInfomation(with: locations).location
        else {
            NotificationCenter.default._post(name: Notification._name(._locationServices), object: code); return
        }
        
        location.coordinate._placemark { (result) in
            
            switch result {
            case .failure(_): NotificationCenter.default._post(name: Notification._name(._locationServices), object: code)
            case .success(let placemark):
                manager.stopUpdatingLocation()
                code.GPS = placemark.isoCountryCode
                NotificationCenter.default._post(name: Notification._name(._locationServices), object: code)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension Utility: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { countryCode(with: manager, locations: locations) }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) { locationManagerStatus(manager, status: status) }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        let code = CLLocationManager._locationCountryCode()
        NotificationCenter.default._post(name: Notification._name(._locationServices), object: code)
    }
}
