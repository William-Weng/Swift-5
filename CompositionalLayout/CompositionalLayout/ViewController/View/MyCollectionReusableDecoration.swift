//
//  MyCollectionReusableDecoration.swift
//  CompositionalLayout
//
//  Created by William.Weng on 2021/11/2.
//

import UIKit
import WWPrint

final class MyCollectionReusableDecoration: UICollectionReusableView, CellReusable, NibOwnerLoadable {

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromXib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with indexPath: IndexPath) {}
}
