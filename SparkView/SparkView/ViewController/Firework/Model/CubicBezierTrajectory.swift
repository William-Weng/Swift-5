//
//  CubicBezierTrajectory.swift
//  SparkView
//
//  Created by William on 2019/8/27.
//  Copyright © 2019 William. All rights reserved.
//
/// [貝茲曲線](https://zh.wikipedia.org/wiki/貝茲曲線)
/// [三種類型的貝茲曲線](https://docs.microsoft.com/zh-tw/xamarin/xamarin-forms/user-interface/graphics/skiasharp/curves/beziers)

import UIKit

// MARK: - 火花路徑資訊 (三階貝茲曲線的點 / 路徑)
struct CubicBezierTrajectory: SparkTrajectory {
    
    private let controlPointCount = 4
    
    var points = [CGPoint]()
    var path: UIBezierPath { return bezierTrajectoryMaker() }
    
    init(points _points: [CGPoint]) {
       appnedPoints(_points)
    }
}

// MARK: - 小工具
extension CubicBezierTrajectory {
    
    /// 記錄貝茲曲線的點
    private mutating func appnedPoints(_ newPoints: [CGPoint]) {
        for newPoint in newPoints {
            points.append(newPoint)
        }
    }
    
    /// 產生三階貝茲曲線
    private func bezierTrajectoryMaker() -> UIBezierPath {
        
        guard points.count == controlPointCount else { fatalError("需要\(controlPointCount)個點") }
        
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: points[0])
        bezierPath.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
        
        return bezierPath
    }
}
