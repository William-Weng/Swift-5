//
//  Extension+.swift
//  CompositionalLayout_TableView
//
//  Created by William.Weng on 2020/9/14.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

// MARK: - UIColr (class function)
extension UIColor {
    
    /// UIColor(red: 255, green: 255, blue: 255, alpha: 255)
    convenience init(red: Int, green: Int, blue: Int, alpha: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
    
    /// UIColor(red: 255, green: 255, blue: 255)
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: red, green: green, blue: blue, alpha: 255)
    }
    
    /// UIColor(rgb: 0xFFFFFF)
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
    
    /// UIColor(rgba: 0xFFFFFFFF)
    convenience init(rgba: Int) {
        self.init(red: (rgba >> 24) & 0xFF, green: (rgba >> 16) & 0xFF, blue: (rgba >> 8) & 0xFF, alpha: (rgba) & 0xFF)
    }
    
    /// UIColor(rgb: #FFFFFF)
    convenience init(rgb: String) {
        
        let ruleRGB = "^#[0-9A-Fa-f]{6}$"
        let predicateRGB = NSPredicate(format: "SELF MATCHES %@", ruleRGB)
        
        guard predicateRGB.evaluate(with: rgb),
              let string = rgb.split(separator: "#").last,
              let number = Int.init(string, radix: 16)
        else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0); return
        }
        
        self.init(rgb: number)
    }
    
    /// UIColor(rgba: #FFFFFFFF)
    convenience init(rgba: String) {
        
        let ruleRGBA = "^#[0-9A-Fa-f]{8}$"
        let predicateRGBA = NSPredicate(format: "SELF MATCHES %@", ruleRGBA)
        
        guard predicateRGBA.evaluate(with: rgba),
              let string = rgba.split(separator: "#").last,
              let number = Int.init(string, radix: 16)
        else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0); return
        }
        
        self.init(rgba: number)
    }
}

// MARK: - Collection (class function)
extension Collection {

    /// 為 Collection 加上安全取值特性 => nil
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UICollectionView (class function)
extension UICollectionView {
    
    /// 取得UICollectionViewCell
    /// let cell = collectionView._reusableCell(at: indexPath) as MyCollectionViewCell
    func _reusableCell<T: ReusableCell>(at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else { fatalError("UICollectionViewCell Error") }
        return cell
    }
    
    /// 取得UICollectionReusableView
    /// let header = collectionView._reusableHeader(at: indexPath, forKind = .header) as MyCollectionReusableHeader
    func _reusableSupplementaryView<T: ReusableCell>(at indexPath: IndexPath, ofKind kind: Utility.ReusableSupplementaryViewKind) -> T where T: UICollectionReusableView {
        guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: T.identifier, for: indexPath) as? T else { fatalError("UICollectionReusableView Error") }
        return supplementaryView
    }
    
    /// 註冊Cell (使用Class)
    func _registerCell<T: ReusableCell>(cellClass: T.Type) { register(cellClass.self, forCellWithReuseIdentifier: cellClass.identifier) }
    
    /// 註冊Cell (使用xib / code)
    func  _registerSupplementaryView<T: ReusableCell>(cellClass: T.Type, ofKind kind: Utility.ReusableSupplementaryViewKind) { register(T.self, forSupplementaryViewOfKind: "\(kind)", withReuseIdentifier: T.identifier) }
}
