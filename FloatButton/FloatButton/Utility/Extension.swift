//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2022/12/15.
//

import UIKit

// MARK: - Int (class function)
extension Int {
    
    /// 轉成CGFloat
    /// - Returns: CGFloat
    func _CGFloat() -> CGFloat { return CGFloat(self) }
}

// MARK: - CALayer (class function)
extension CALayer {
    
    /// 設定圓角
    /// - 可以個別設定要哪幾個角
    /// - 預設是四個角全是圓角
    /// - Parameters:
    ///   - radius: 圓的半徑
    ///   - corners: 圓角要哪幾個邊
    func _maskedCorners(radius: CGFloat, corners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]) {
        self.masksToBounds = true
        self.maskedCorners = corners
        self.cornerRadius = radius
    }
}


// MARK: - Collection (override class function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

