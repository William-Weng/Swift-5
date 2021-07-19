
//
//  Utility.swift
//  AppDynamicIcons
//
//  Created by William.Weng on 2020/11/9.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

// MARK: - Utility (單例)
final class Utility: NSObject {
    static let shared = Utility()
    private override init() {}
}

extension Utility {

    /// 自訂錯誤
    enum MyError: Error { case unknown }
    
    /// 讀取info.plist的欄位資訊
    /// - CFBundleShortVersionString...
    func infoDictionary(with key: String) -> Any? { return Bundle.main.infoDictionary?[key] }
    
    /// 取得動態Icon的相關資訊
    /// - info.plist => CFBundleIcons => CFBundleAlternateIcons
    /// - [IconKey]
    func appDynamicIcons() -> [String]? {
        
        guard let iconsInfo = infoDictionary(with: "CFBundleIcons") as? [String: Any],
              let alternateIcons = iconsInfo["CFBundleAlternateIcons"] as? [String: Any],
              let iconKeys = Optional.some(alternateIcons.keys.sorted())
        else {
            return nil
        }
        
        return iconKeys
    }
    
    /// 更換APP ICON
    /// - [動態更換APP ICON](https://www.cnblogs.com/zhanggui/p/6674858.html)
    /// - 會回傳現在使用的ICON名稱
    /// - Key = PrimaryIcon就是原本的ICON => nil
    func dynamicAppIcon(for key: String?, result: @escaping ((Result<String?, Error>) -> Void)) {
        
        guard UIApplication.shared.supportsAlternateIcons else { result(.failure(Utility.MyError.unknown)); return }
                
        UIApplication.shared.setAlternateIconName(key) { (error) in
            if let error = error { result(.failure(error)); return }
            result(.success(UIApplication.shared.alternateIconName))
        }
    }
}
