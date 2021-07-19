//
//  Extension.swift
//  SparkView
//
//  Created by William on 2019/8/26.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 增加加法 / 乘法
extension CGPoint {
    
    mutating func add(vector: CGVector) {
        x += vector.dx
        y += vector.dy
    }
    
    mutating func multiply(by value: CGFloat) {
        x *= value
        y *= value
    }
    
    func adding(vector: CGVector) -> CGPoint {
        var _self = self
        _self.add(vector: vector)
        return _self
    }
}

