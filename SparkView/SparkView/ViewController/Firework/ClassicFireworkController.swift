//
//  ClassicFireworkController.swift
//  SparkView
//
//  Created by William on 2019/8/30.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class ClassicFireworkController {
    
    var sparkAnimator: SparkViewAnimator { return ClassicFireworkAnimator() }
    
    func createFirework(at origin: CGPoint, sparkSize: CGSize, scale: CGFloat) -> Firework {
        return ClassicFirework(origin: origin, sparkSize: sparkSize, scale: scale)
    }
    
    /// 讓煙花在其源視圖的角落附近爆開
    func addFireworks(count fireworksCount: Int = 1, sparks sparksCount: Int, around sourceView: UIView, sparkSize: CGSize = CGSize(width: 7, height: 7), scale: CGFloat = 45.0, maxVectorChange: CGFloat = 15.0, animationDuration: TimeInterval = 0.5, canChangeZIndex: Bool = true) {
        
        guard let superview = sourceView.superview else { fatalError() }
        
        let origins = [
            CGPoint(x: sourceView.frame.minX, y: sourceView.frame.minY),
            CGPoint(x: sourceView.frame.maxX, y: sourceView.frame.minY),
            CGPoint(x: sourceView.frame.minX, y: sourceView.frame.maxY),
            CGPoint(x: sourceView.frame.maxX, y: sourceView.frame.maxY),
        ]
        
        for _ in 0..<fireworksCount {
            
            let index = Int(arc4random_uniform(UInt32(origins.count)))
            let origin = origins[index].adding(vector: self.randomChangeVector(max: maxVectorChange))
            let firework = createFirework(at: origin, sparkSize: sparkSize, scale: scale)
            
            for sparkIndex in 0..<sparksCount {
                
                let spark = firework.sparkHelper(at: sparkIndex)
                spark.sparkView.isHidden = true
                superview.addSubview(spark.sparkView)
                
                if canChangeZIndex {
                    let zIndexChange: CGFloat = arc4random_uniform(2) == 0 ? -1 : +1
                    spark.sparkView.layer.zPosition = sourceView.layer.zPosition + zIndexChange
                } else {
                    spark.sparkView.layer.zPosition = sourceView.layer.zPosition
                }
                
                sparkAnimator.animate(spark: spark, duration: animationDuration)
            }
        }
    }
}

// MARK: - 小工具
extension ClassicFireworkController {
    
    private func randomChangeVector(max: CGFloat) -> CGVector {
        return CGVector(dx: self.randomChange(max: max), dy: self.randomChange(max: max))
    }
    
    private func randomChange(max: CGFloat) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(max))) - (max / 2.0)
    }
}
