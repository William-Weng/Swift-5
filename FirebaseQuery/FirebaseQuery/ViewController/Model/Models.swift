//
//  Models.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/12.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 書籍模型
class Book {
    
    private(set) var isbn: Int?
    private(set) var title: String?
    private(set) var url: String?
    private(set) var icon: String?
    private(set) var count: Int?
    private(set) var timestamp: Int?
    
    /// 初始化設定值
    init(isbn: Int?, title: String?, url: String?, icon: String?, count: Int?, timestamp: Int?) {
        self.isbn = isbn
        self.title = title
        self.url = url
        self.icon = icon
        self.count = count
        self.timestamp = timestamp
    }
    
    /// 轉成Dictionary
    func dictionary() -> [String: Any?] {
        
        let dictionary = [
            "\(BookField.ISBN)": isbn,
            "\(BookField.Title)": title,
            "\(BookField.URL)": url,
            "\(BookField.Icon)": icon,
            "\(BookField.Count)": count,
            "\(BookField.Timestamp)": timestamp,
        ] as [String : Any?]
        
        return dictionary
    }
    
    /// 建立數值
    static func builder(with book: [String: Any]) -> Book {
        
        let isbn = book["\(BookField.ISBN)"] as? Int
        let title = book["\(BookField.Title)"] as? String
        let url = book["\(BookField.URL)"] as? String
        let icon = book["\(BookField.Icon)"] as? String
        let count = book["\(BookField.Count)"] as? Int
        let timestamp = book["\(BookField.Timestamp)"] as? Int

        return Book(isbn: isbn, title: title, url: url, icon: icon, count: count, timestamp: timestamp)
    }
}
