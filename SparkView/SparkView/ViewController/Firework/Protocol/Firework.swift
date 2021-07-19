//
//  Firework.swift
//  SparkView
//
//  Created by William on 2019/8/27.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 火花的基本數據與功能
protocol Firework {
    
    var origin: CGPoint { get set }                                     /* 煙花的初始位置 */
    var scale: CGFloat { get set }                                      /* 煙花的放大比例 */
    var sparkSize: CGSize { get set }                                   /* 煙花的大小 */
    var trajectoryFactory: SparkTrajectoryFactory { get }               /* 煙花的軌跡 */
    var sparkViewFactory: SparkViewFactory { get }                      /* 煙花的View */
    
    func sparkViewFactoryData(at index: Int) -> SparkViewFactoryData    /* 煙花的資料 */
    func sparkView(at index: Int) -> SparkView                          /* 煙花的View */
    func trajectory(at index: Int) -> SparkTrajectory                   /* 煙花的軌跡 */
}

// MARK: - 小工具
extension Firework {
    
    /// 用於返回火花的View及對應的軌跡
    func sparkHelper(at index: Int) -> FireworkSpark {
        return FireworkSpark(sparkView(at: index), trajectory(at: index))
    }
}
