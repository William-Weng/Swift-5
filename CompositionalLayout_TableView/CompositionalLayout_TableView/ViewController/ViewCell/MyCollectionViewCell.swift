//
//  MyCollectionViewCell.swift
//  CompositionalLayout_TableView
//
//  Created by William.Weng on 2020/9/8.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

final class MyCollectionViewCell: UICollectionViewCell, ReusableCell {
    
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    private(set) var indexPath: IndexPath = []
        
    func configure(with indexPath: IndexPath) {
        
        var color: UIColor = .white
        var image: UIImage = #imageLiteral(resourceName: "Green")
        
        switch indexPath.row % 3 {
        case 0: color = .red; image = #imageLiteral(resourceName: "Green")
        case 1:  color = .green; image = #imageLiteral(resourceName: "Blue")
        case 2: color = .yellow; image = #imageLiteral(resourceName: "Yellow")
        default: color = .white; image = #imageLiteral(resourceName: "Green")
        }
        
        self.indexPath = indexPath
        self.myImageView.image = image
        self.backgroundColor = color
        self.myLabel.text = "\(indexPath)"
    }
}

final class MyCollectionReusableHeader: UICollectionReusableView, ReusableCell {
        
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    private(set) var indexPath: IndexPath = []
        
    func configure(with indexPath: IndexPath) {
        self.indexPath = indexPath
        self.backgroundColor = .yellow
        self.myImageView.image = #imageLiteral(resourceName: "Header")
        self.myLabel.text = "\(indexPath.section)"
    }
}

final class MyCollectionReusableFooter: UICollectionReusableView, ReusableCell {
    
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    private(set) var indexPath: IndexPath = []
        
    func configure(with indexPath: IndexPath) {
        self.indexPath = indexPath
        self.backgroundColor = UIColor(rgb: "#ff0000")
        self.myImageView.image = #imageLiteral(resourceName: "Footer")
        self.myLabel.text = "\(indexPath.section)"
    }
}
