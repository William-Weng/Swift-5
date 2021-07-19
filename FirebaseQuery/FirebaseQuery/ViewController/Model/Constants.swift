//
//  Constants.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/12.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - Realtime Database的讀取類型
enum RealtimeDatabaseType {
    case single
    case realtime
}

// MARK: - Book的JSON欄位名稱
enum BookField: String {
    case Books = "Books"
    case BarCode = "BarCode"
    case ISBN = "ISBN"
    case Title = "Title"
    case URL = "URL"
    case Icon = "Icon"
    case Count = "Count"
    case Timestamp = "Timestamp"
}

// MARK: - Tabbar分頁的代號
enum TabBarType {
    case stock
    case cart
    case plus
    case minus
    case fix
}

// MARK: - CustomStringConvertible
extension BookField: CustomStringConvertible {
    var description: String { return rawValue }
}

// MARK: - 小工具
extension BookField {
    
    /// 在Firebase上的欄位位置 (Books/BarCode/9789573285304/ISBN)
    func realPath(withBarCode barcode: Int? = nil) -> String {
        
        switch self {
        case .Books:
            return "\(self)"
        case .ISBN, .Title, .URL, .Icon, .Count, .Timestamp:
            return "\(BookField.Books)/\(BookField.BarCode)/\(barcode!)/(self)"
        case .BarCode:
            if let barcode = barcode { return "\(BookField.Books)/\(self)/\(barcode)" }
            return "\(BookField.Books)/\(self)/"
        }
    }
}
