//
//  Views.swift
//  SparkView
//
//  Created by William on 2019/8/26.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

/// MARK: - 火花View (基本型)
class SparkView: UIView {}

/// MARK: - 火花View (圓形的)
final class CircleColorSparkView: SparkView {
    
    init(color: UIColor, size: CGSize) {
        super.init(frame: CGRect(origin: .zero, size: size))
        initSetting(with: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetting()
    }
    
    /// 初始化設定 (圓角 / 顏色)
    private func initSetting(with color: UIColor? = nil) {
        backgroundColor = color
        layer.cornerRadius = frame.width / 2.0
    }
}
