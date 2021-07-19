//
//  Model.swift
//  SparkView
//
//  Created by William on 2019/8/26.
//  Copyright © 2019 William. All rights reserved.
//
/// [Swift 中的選項集合](https://swift.gg/2016/10/25/swift-option-sets/)

import UIKit

class ClassicFirework: Firework {
    
    var origin: CGPoint
    var scale: CGFloat
    var sparkSize: CGSize
    var trajectoryFactory: SparkTrajectoryFactory { return ClassicSparkTrajectoryFactory() }
    var sparkViewFactory: SparkViewFactory { return CircleColorSparkViewFactory() }
    
    var maxChangeValue: Int { return 10 }
    var classicTrajectoryFactory: ClassicSparkTrajectoryFactoryProtocol { return trajectoryFactory as! ClassicSparkTrajectoryFactoryProtocol }

    private var quarters = [Quarter]()
    
    init(origin: CGPoint, sparkSize: CGSize, scale: CGFloat) {
        self.origin = origin
        self.scale = scale
        self.sparkSize = sparkSize
        self.quarters = shuffledQuarters()
    }
    
    func sparkViewFactoryData(at index: Int) -> SparkViewFactoryData { return DefaultSparkViewFactoryData(size: sparkSize, index: index) }
    func sparkView(at index: Int) -> SparkView { return sparkViewFactory.create(with: sparkViewFactoryData(at: index)) }
    func trajectory(at index: Int) -> SparkTrajectory { return trajectoryMaker(at: index) }
}

// MARK: - 主工具
extension ClassicFirework {
    
    private func trajectoryMaker(at index: Int) -> SparkTrajectory {
        
        let quarter = quarters[index]
        let flipOptions = flipOptionsMaker(for: quarter)
        let changeVector = randomChangeVector(flipOptions: flipOptions, maxValue: maxChangeValue)
        let sparkOrigin = origin.adding(vector: changeVector)
        
        return randomTrajectory(flipOptions: flipOptions).scale(by: scale).shift(to: sparkOrigin)
    }
}

// MARK: - 小工具
extension ClassicFirework {
    
    /// 判斷是否要映射 (mirror一組一樣的)
    private func flipOptionsMaker(`for` quarter: Quarter) -> FlipOptions {
        
        var flipOptions: FlipOptions = []
        
        if quarter == .bottomLeft || quarter == .topLeft { flipOptions.insert(.horizontally) }
        if quarter == .bottomLeft || quarter == .bottomRight { flipOptions.insert(.vertically) }
        
        return flipOptions
    }
    
    /// 產生隨機的位置
    private func shuffledQuarters() -> [Quarter] {
        
        var quarters: [Quarter] = [.topRight, .topRight, .bottomRight, .bottomRight, .bottomLeft, .bottomLeft, .topLeft, .topLeft]
        var shuffled = [Quarter]()
        
        for _ in 0..<quarters.count {
            let randomIndex = Int(arc4random_uniform(UInt32(quarters.count)))
            shuffled.append(quarters[randomIndex])
            quarters.remove(at: randomIndex)
        }
        
        return shuffled
    }
    
    /// 產生隨機火花 (跟據flipOptions來決定是否要處理)
    private func randomTrajectory(flipOptions: FlipOptions) -> SparkTrajectory {
        
        var trajectory: SparkTrajectory
        
        if flipOptions.contains(.vertically) {
            trajectory = classicTrajectoryFactory.randomBottomRight
        } else {
            trajectory = classicTrajectoryFactory.randomTopRight
        }
        
        return flipOptions.contains(.horizontally) ? trajectory.flip() : trajectory
    }
    
    /// 產生隨機向量
    private func randomChangeVector(flipOptions: FlipOptions, maxValue: Int) -> CGVector {
        
        let values = (randomChange(maxValue), randomChange(maxValue))
        let changeX = flipOptions.contains(.horizontally) ? -values.0 : values.0
        let changeY = flipOptions.contains(.vertically) ? values.1 : -values.0
        
        return CGVector(dx: changeX, dy: changeY)
    }
    
    /// 產生隨機數
    private func randomChange(_ maxValue: Int) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(maxValue)))
    }
}
