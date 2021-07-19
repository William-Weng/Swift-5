//
//  ClassicFireworkAnimator.swift
//  SparkView
//
//  Created by William on 2019/8/29.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 火花的動畫
struct ClassicFireworkAnimator: SparkViewAnimator {
    
    /// 火花的動畫 (時間)
    func animate(spark: FireworkSpark, duration: TimeInterval) {
        
        spark.sparkView.isHidden = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({ spark.sparkView.removeFromSuperview() })
        
        let randomScale = randomScaleMaker()
        let randomTransform = randomTransformMaker(with: randomScale)
        let groupAnimation = groupAnimationMaker(spark: spark, duration: duration, transform: randomTransform)

        spark.sparkView.layer.transform = randomTransform.to
        spark.sparkView.layer.add(groupAnimation, forKey: "spark-animation")

        CATransaction.commit()
    }
}

// MARK: - 小工具
extension ClassicFireworkAnimator {
    
    /// 火花的組合動畫
    private func groupAnimationMaker(spark: FireworkSpark, duration: TimeInterval, transform: RandomTransform) -> CAAnimationGroup {
        
        let groupAnimation = CAAnimationGroup()
        
        groupAnimation.animations = [
            positionAnimationMaker(spark: spark, duration: duration),
            opacityAnimationMaker(spark: spark, duration: duration),
            transformAnimationMaker(spark: spark, duration: duration, transform: transform),
        ]
        
        groupAnimation.duration = duration
        
        return groupAnimation
    }
    
    /// 火花的位置動畫
    private func positionAnimationMaker(spark: FireworkSpark, duration: TimeInterval) -> CAKeyframeAnimation {
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "\(AnimationKeyPath.position)")
        
        positionAnimation.path = spark.trajectory.path.cgPath
        positionAnimation.calculationMode = .linear
        positionAnimation.rotationMode = .rotateAuto
        positionAnimation.duration = duration
        
        return positionAnimation
    }
    
    /// 火花的不透明度動畫
    private func opacityAnimationMaker(spark: FireworkSpark, duration: TimeInterval) -> CAKeyframeAnimation {
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "\(AnimationKeyPath.opacity)")
        
        opacityAnimation.values = [1.0, 0.0]
        opacityAnimation.keyTimes = [0.95, 0.98]
        opacityAnimation.duration = duration
        spark.sparkView.layer.opacity = 0.0
        
        return opacityAnimation
    }
    
    /// 火花的轉場動畫
    private func transformAnimationMaker(spark: FireworkSpark, duration: TimeInterval, transform: RandomTransform) -> CAKeyframeAnimation {
        
        let transformAnimation = CAKeyframeAnimation(keyPath: "\(AnimationKeyPath.transform)")
        
        transformAnimation.values = [
            NSValue(caTransform3D: transform.from),
            NSValue(caTransform3D: transform.by),
            NSValue(caTransform3D: transform.to),
        ]
        
        transformAnimation.duration = duration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        return transformAnimation
    }
    
    /// 火花的縮放比例
    private func randomScaleMaker() -> RandomScale {
        
        let randomMaxScale = 1.0 + CGFloat(arc4random_uniform(7)) / 10.0
        let randomMinScale = 0.5 + CGFloat(arc4random_uniform(3)) / 10.0

        return (max: randomMaxScale, min: randomMinScale)
    }

    /// 火花的CATransform3D參數
    private func randomTransformMaker(with scale: RandomScale) -> RandomTransform {
        
        let randomScale = randomScaleMaker()
        
        let fromTransform = CATransform3DIdentity
        let byTransform = CATransform3DScale(fromTransform, randomScale.max, randomScale.max, randomScale.max)
        let toTransform = CATransform3DScale(CATransform3DIdentity, randomScale.min, randomScale.min, randomScale.min)
        
        return (fromTransform, byTransform, toTransform)
    }
}
