//
//  Constant.swift
//  PerpetualCalendar
//
//  Created by William.Weng on 2021/7/19.
//

import UIKit

// MARK: - Utility (單例)
final class Constant: NSObject {}

// MARK: - typealias
extension Constant {
    
    typealias CustomKeyborad = (keyboard: UIPickerView, toolbar: UIToolbar)
}

// MARK: - enum
extension Constant {
    
    /// [時間的格式](http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns)
    enum DateFormat: String {
        case full = "yyyy-MM-dd HH:mm:ss ZZZ"
        case long = "yyyy-MM-dd HH:mm:ss"
        case middle = "yyyy-MM-dd HH:mm"
        case short = "yyyy-MM-dd"
        case timeZone = "ZZZ"
        case time = "HH:mm:ss"
        case yearMonth = "yyyy-MM"
        case monthDay = "MM-dd"
        case day = "dd"
    }
    
    /// [時區代號](https://apphelp.readdle.com/calendars/index.php?pg=kb.page&id=588)
    enum TimeZoneIdentifier: String {
        case UTC = "UTC"
        case Asia_Taipei = "Asia/Taipei"
    }
}
