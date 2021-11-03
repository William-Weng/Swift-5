//
//  MyCollectionViewCell.swift
//  CompositionalLayout
//
//  Created by William.Weng on 2021/11/2.
//

import UIKit
import WWPrint

final class MyCollectionViewCell: UICollectionViewCell, CellReusable {
    
    @IBOutlet weak var myLabel: UILabel!
    
    static var dataSource = [1...20]._repeating(text: " - 測試用")
    
    func configure(with indexPath: IndexPath) {
        myLabel.text = Self.dataSource[safe: indexPath.row]
        self.backgroundColor = (indexPath.row % 2 == 0) ? .lightGray : .green
    }
}
