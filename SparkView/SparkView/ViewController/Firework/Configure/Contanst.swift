//
//  Contanst.swift
//  SparkView
//
//  Created by William on 2019/8/26.
//  Copyright © 2019 William. All rights reserved.
//
/// [Bezier Curves](https://www.desmos.com/calculator/epunzldltu)

import UIKit

// MARK: - 記錄一些別名
typealias FireworkSpark = (sparkView: SparkView, trajectory: SparkTrajectory)
typealias RandomTransform = (from: CATransform3D, by: CATransform3D, to: CATransform3D)
typealias RandomScale = (max: CGFloat, min: CGFloat)

// MARK: - 記錄一些常數
class Contanst: NSObject {

    static var topRightCubicBezierTrajectorys: [[CGPoint]] { return topRightCubicBezierTrajectorysMaker() }
    static var bottomRightCubicBezierTrajectorys: [[CGPoint]] { return bottomRightCubicBezierTrajectorysMaker() }
    static var sparkColorSet: [UIColor] { return sparkColorSetMaker() }
    
    /// 右上的火花路徑
    private static func topRightCubicBezierTrajectorysMaker() -> [[CGPoint]] {
        
        let paths: [[CGPoint]] = [
            [CGPoint(x: 0, y: 0), CGPoint(x: 0.31, y: -0.46), CGPoint(x: 0.74, y: -0.29), CGPoint(x: 0.99, y: 0.12)],
            [CGPoint(x: 0, y: 0), CGPoint(x: 0.31, y: -0.46), CGPoint(x: 0.62, y: -0.49), CGPoint(x: 0.99, y: 0.12)],
            [CGPoint(x: 0, y: 0), CGPoint(x: 0.10, y: -0.54), CGPoint(x: 0.44, y: -0.53), CGPoint(x: 0.66, y: -0.30)],
            [CGPoint(x: 0, y: 0), CGPoint(x: 0.19, y: -0.46), CGPoint(x: 0.41, y: -0.53), CGPoint(x: 0.65, y: -0.45)],
        ]
        
        return paths
    }
    
    /// 右下的火花路徑
    private static func bottomRightCubicBezierTrajectorysMaker() -> [[CGPoint]] {
        
        let paths: [[CGPoint]] = [
            [CGPoint(x: 0, y: 0), CGPoint(x: 0.42, y: -0.01), CGPoint(x: 0.68, y: 0.11), CGPoint(x: 0.87, y: 0.44)],
            [CGPoint(x: 0, y: 0), CGPoint(x: 0.21, y: 0.05), CGPoint(x: 0.31, y: 0.19), CGPoint(x: 0.32, y: 0.45)],
            [CGPoint(x: 0, y: 0), CGPoint(x: 0.21, y: 0.05), CGPoint(x: 0.31, y: 0.19), CGPoint(x: 0.32, y: 0.45)],
            [CGPoint(x: 0, y: 0), CGPoint(x: 0.18, y: 0.00), CGPoint(x: 0.31, y: 0.11), CGPoint(x: 0.35, y: 0.25)],
        ]
        
        return paths
    }
    
    /// 自訂顏色
    private static func sparkColorSetMaker() -> [UIColor] {
        return [#colorLiteral(red: 1, green: 0.9821474439, blue: 0.2586054332, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
    }
}

/// 翻轉的類型 (水平 / 垂直)
struct FlipOptions: OptionSet {
    
    let rawValue: Int
    
    static let horizontally = FlipOptions(rawValue: 1 << 0)
    static let vertically = FlipOptions(rawValue: 1 << 1)
}

/// MARK: - 火花的位置 (四個象限)
enum Quarter {
    case topRight
    case bottomRight
    case bottomLeft
    case topLeft
}

/// MARK: - CAKeyframeAnimation的Key值
enum AnimationKeyPath: String, CustomStringConvertible {
    
    var description: String { return rawValue }
    
    case position = "position"
    case transform = "transform"
    case opacity = "opacity"
}

/// MARK: - 火花的資料 (預設型)
struct DefaultSparkViewFactoryData: SparkViewFactoryData {
    public let size: CGSize
    public let index: Int
}
