//
//  Protocol.swift
//  SparkView
//
//  Created by William on 2019/8/26.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 火花隨機軌跡 (基本型)
protocol SparkTrajectoryFactory {}

// MARK: - 火花隨機軌跡 (一般型)
protocol ClassicSparkTrajectoryFactoryProtocol: SparkTrajectoryFactory {
    var randomTopRight: SparkTrajectory { get }                     /* 火花隨機軌跡 (右上) */
    var randomBottomRight: SparkTrajectory { get }                  /* 火花隨機軌跡 (右下) */
}

// MARK: - 火花資訊
protocol SparkViewFactoryData {
    var size: CGSize { get }                                        /* 火花大小 */
    var index: Int { get }                                          /* 火花序號 */
}

// MARK: - 火花工廠
protocol SparkViewFactory {
    func create(with data: SparkViewFactoryData) -> SparkView       /* 產生火花View */
}

// MARK: - 火花動畫
protocol SparkViewAnimator {
    func animate(spark: FireworkSpark, duration: TimeInterval)      /* 火花的動畫 */
}

