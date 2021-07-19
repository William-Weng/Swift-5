//
//  MyTableViewCell.swift
//  Firebase_HelloWorld
//
//  Created by William on 2019/6/11.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 書籍的Cell
class MyTableViewCell: UITableViewCell {
    
    public static let identifier = "MyTableViewCell"
    
    @IBOutlet var isbnLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
    /// 設定初值
    func configure(_ bookInfomation: BookInfomation) {
        isbnLabel.text = String(bookInfomation.isbn ?? 0)
        titleLabel.text = bookInfomation.title
    }
}
