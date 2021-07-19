//
//  Model.swift
//  Firebase_HelloWorld
//
//  Created by William on 2019/6/11.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 書籍資料的長相
struct BookInfomation {
    
    private(set) var isbn: Int?
    private(set) var title: String?
    private(set) var url: URL?
    
    /// 設定初值
    static func configure(with data: [String: Any]) -> BookInfomation {
        
        let isbn = data["ISBN"] as? Int
        let title = data["Title"] as? String
        let url = URL.init(string: data["URL"] as? String ?? "")
        
        return BookInfomation(isbn: isbn, title: title, url: url)
    }
}
