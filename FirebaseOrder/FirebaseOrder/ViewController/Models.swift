//
//  Models.swift
//  FirebaseOrder
//
//  Created by William on 2019/6/20.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 書籍
struct Book {
    
    /// 書籍欄位名稱
    enum Field: String {
        case BarCode = "BarCode"
        case Count = "Count"
        case ISBN = "ISBN"
        case Timestamp = "Timestamp"
        case Title = "Title"
        case URL = "URL"
    }
    
    var ISBN: Int?
    var Title: String?
}
