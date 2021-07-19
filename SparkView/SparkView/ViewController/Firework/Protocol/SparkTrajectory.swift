//
//  SparkTrajectory.swift
//  SparkView
//
//  Created by William on 2019/8/27.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 火花軌跡的屬性
protocol SparkTrajectory {
    var points: [CGPoint] { get set }   /* 軌跡上的點 */
    var path: UIBezierPath { get }      /* 軌跡的路徑 */
}

// MARK: - 小工具
extension SparkTrajectory {
    
    /// 水平翻轉 (X軸)
    func flip() -> SparkTrajectory {
        
        var _self = self
        
        for index in 0..<points.count {
            _self.points[index].x *= -1
        }
        
        return _self
    }
    
    /// 放大 (縮小)
    func scale(by value: CGFloat) -> SparkTrajectory {
        
        var _self = self
        
        for index in 0..<points.count {
            _self.points[index].multiply(by: value)
        }
        
        return _self
    }
    
    /// 偏移 (移動)
    func shift(to point: CGPoint) -> SparkTrajectory {
        
        var _self = self
        
        for index in 0..<points.count {
            _self.points[index].add(vector: CGVector(dx: point.x, dy: point.y))
        }
        
        return _self
    }
}
