//
//  CircleColorSparkViewFactory.swift
//  SparkView
//
//  Created by William on 2019/8/27.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 火花工廠 (產生圓形的SparkView)
public class CircleColorSparkViewFactory: SparkViewFactory {
    
    public var colors: [UIColor] { return Contanst.sparkColorSet }
    
    func create(with data: SparkViewFactoryData) -> SparkView {
        return sparkViewMaker(with: data)
    }
}

// MARK: - 小工具
extension CircleColorSparkViewFactory {
    
    /// 產生彩色的火花View
    private func sparkViewMaker(with data: SparkViewFactoryData) -> SparkView {
        
        let index = data.index % colors.count
        let color = colors[index]
        
        return CircleColorSparkView(color: color, size: data.size)
    }
}
