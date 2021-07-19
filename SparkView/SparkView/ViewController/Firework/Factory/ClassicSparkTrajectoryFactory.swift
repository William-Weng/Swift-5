//
//  Utility.swift
//  SparkView
//
//  Created by William on 2019/8/26.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 產生火花軌跡工廠
final class ClassicSparkTrajectoryFactory: ClassicSparkTrajectoryFactoryProtocol {
    
    var randomTopRight: SparkTrajectory { return randomTopRightMaker() }
    var randomBottomRight: SparkTrajectory { return randomBottomRightMaker() }
}

// MARK: - 小工具
extension ClassicSparkTrajectoryFactory {
    
    /// 產生隨機的火花軌跡
    private func randomTopRightMaker() -> SparkTrajectory {
        let topRight = topRightSparkTrajectorysMaker()
        return topRight[randomIndex(with: topRight.count)]
    }
    
    /// 產生隨機的火花軌跡
    private func randomBottomRightMaker() -> SparkTrajectory {
        let bottomRight = bottomRightSparkTrajectorysMaker()
        return bottomRight[randomIndex(with: bottomRight.count)]
    }
    
    /// [Path] => [CubicBezierTrajectory]
    private func topRightSparkTrajectorysMaker() -> [SparkTrajectory] {
        
        let pathsArray = Contanst.topRightCubicBezierTrajectorys
        var bezierTrajectoryArray = [CubicBezierTrajectory]()
        
        for paths in pathsArray {
            bezierTrajectoryArray.append(CubicBezierTrajectory(points: paths))
        }
        
        return bezierTrajectoryArray
    }
    
    /// [Path] => [CubicBezierTrajectory]
    private func bottomRightSparkTrajectorysMaker() -> [SparkTrajectory] {
        
        let pathsArray = Contanst.bottomRightCubicBezierTrajectorys
        var bezierTrajectoryArray = [CubicBezierTrajectory]()
        
        for paths in pathsArray {
            bezierTrajectoryArray.append(CubicBezierTrajectory(points: paths))
        }
        
        return bezierTrajectoryArray
    }
    
    /// 產生隨機數
    private func randomIndex(with count: Int) -> Int {
        return Int(arc4random_uniform(UInt32(count)))
    }
}

