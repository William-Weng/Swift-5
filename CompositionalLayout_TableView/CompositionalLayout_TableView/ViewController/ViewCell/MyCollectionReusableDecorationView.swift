//
//  MyCollectionReusableDecorationView.swift
//  CompositionalLayout_TableView
//
//  Created by William.Weng on 2020/9/11.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

final class MyCollectionReusableDecorationView: UICollectionReusableView, ReusableCell, NibOwnerLoadable {
        
    @IBOutlet weak var myImageView: UIImageView!
    
    private(set) var indexPath: IndexPath = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXib()
        myImageView.image = #imageLiteral(resourceName: "Star")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromXib()
        myImageView.image = #imageLiteral(resourceName: "Star")
    }
    
    func configure(with indexPath: IndexPath) {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
