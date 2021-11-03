//
//  MyCollectionReusableBadge.swift
//  CompositionalLayout
//
//  Created by William.Weng on 2021/11/2.
//

import UIKit
import WWPrint

final class MyCollectionReusableBadge: UICollectionReusableView, CellReusable, NibOwnerLoadable {

    @IBOutlet weak var myLabel: UILabel!
    
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
    
    /// [Section Header zIndex in UICollectionView CompositionalLayout - iOS 13](https://stackoverflow.com/questions/60112393/section-header-zindex-in-uicollectionview-compositionallayout-ios-13)
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }
    
    func configure(with indexPath: IndexPath) {
        myLabel.text = "\(indexPath.row)"
    }
}
