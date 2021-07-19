//
//  Cells.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/12.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 庫存商品Cell
class StockTableViewCell: UITableViewCell {

    /* cellReuseIdentifier */
    public static let Identifier = String(describing: StockTableViewCell.self)
    
    @IBOutlet var productIcon: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productBarCodeLabel: UILabel!
    @IBOutlet var productCountLabel: UILabel!
    
    /// 設定樣式
    func configure(with product: Book) {
        productIcon.image = UIImage(named: product.icon ?? "NoImage")
        productNameLabel.text = product.title
        productBarCodeLabel.text = String(product.isbn ?? 0)
        productCountLabel.text = String(product.count ?? 0)
    }
}
