//
//  ViewController.swift
//  EmitterAnimation
//
//  Created by William.Weng on 2020/12/10.
//  Copyright © 2020 William.Weng. All rights reserved.
//
/// [利用 CAEmitterLayer 製作 Xmas 的下雪動畫](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-caemitterlayer-製作-xmas-的下雪動畫-ee5f7cae621e)
/// [Smooth Core Animation Snow Effect](https://medium.com/@satindersingh71/smooth-core-animation-snow-effect-3d93417b96b3)
/// [Merry Christmas – 下雪效果 (CAEmitterLayer + CAEmitterCell)](https://ios.devdon.com/archives/1046)
/// [使用CAEmitterLayer做出雪花煙火效果](https://medium.com/彼得潘的-swift-ios-app-開發教室/使用caemitterlayer做出動態效果-76face1be974)

import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let snowFlakeLayer = CAEmitterLayer._maker(for: .snowFlake, on: view)
        let snowFlakeCell = CAEmitterCell._maker(for: .snowFlake, image: #imageLiteral(resourceName: "SnowFlake"), birthRate: 120, lifetime: 20)
        let christmasSockCell = CAEmitterCell._maker(for: .snowFlake, image: #imageLiteral(resourceName: "ChristmasSock"), birthRate: 30, lifetime: 20)
        let coinCell = CAEmitterCell._maker(for: .snowFlake, image: #imageLiteral(resourceName: "Coin"), birthRate: 30, lifetime: 20)

        snowFlakeLayer.emitterCells = [snowFlakeCell, christmasSockCell, coinCell]

//        let fireworkLayer = CAEmitterLayer._maker(for: .firework, on: view, renderMode: .additive)
//        let fireworkCell = CAEmitterCell._maker(for: .firework, image: #imageLiteral(resourceName: "Circle"), birthRate: 5, lifetime: 2.5, color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
//        fireworkLayer.emitterCells = [fireworkCell]
        
        view.layer.addSublayer(snowFlakeLayer)
    }
}

// MARK: - CAEmitterLayer (static function)
extension CAEmitterLayer {

    /// CAEmitterLayer產生器
    /// - Parameter type: EmitterCell的樣式
    /// - Parameter view: 要在哪個View上顯示
    /// - Parameter frame: 從哪裡開始發射
    /// - Parameter renderMode: 渲染效果
    /// - Returns: CAEmitterLayer
    static func _maker(for type: CAEmitterCell.EmitterCellType, on view: UIView, frame: CGRect? = nil, renderMode: CAEmitterLayerRenderMode? = nil) -> CAEmitterLayer {
        
        switch type {
        case .snowFlake:
            
            let layer = CAEmitterLayer()
                ._setting(position: CGPoint(x: view.bounds.width / 2.0, y: -50), size: CGSize(width: view.bounds.width, height: 0), shape: .line)
                ._frame(frame)
                ._renderMode(renderMode)
                ._timeOffset(offset: 10)
            
            return layer
            
        case .firework:
            
            let layer = CAEmitterLayer()
                ._setting(position: CGPoint(x: view.bounds.width / 2, y: view.bounds.height), size: view.bounds.size)
                ._renderMode(renderMode)
            
            return layer
        }
    }
}

// MARK: - CAEmitterLayer (class function)
extension CAEmitterLayer {
        
    /// 基本設定
    /// - Parameters:
    ///   - position: 發射的位置 => 畫面x軸中心
    ///   - size: 發射的範圍大小 => 全畫面
    ///   - shape: 發射的方式 => 直線 / 圓形 / 矩型…，官方有數學式計算細節
    /// - Returns: CAEmitterLayer
    func _setting(position: CGPoint, size: CGSize, shape: CAEmitterLayerEmitterShape? = nil) -> CAEmitterLayer {
        
        if let shape = shape { self.emitterShape = shape }
        
        self.emitterPosition = position
        self.emitterSize = size
        
        return self
    }
    
    /// 設定發射的開始範圍
    /// - Parameter frame: 從哪裡開始發射
    /// - Returns: CAEmitterLayer
    func _frame(_ frame: CGRect?) -> CAEmitterLayer {
        if let frame = frame { self.frame = frame }
        return self
    }
    
    /// 設定發射的樣式
    /// - Parameter shape: 發射樣式
    /// - Returns: CAEmitterLayer
    func _shape(_ shape: CAEmitterLayerEmitterShape?) -> CAEmitterLayer {
        if let shape = shape { self.emitterShape = shape }
        return self
    }
    
    /// 設定渲染效果
    /// - Parameter renderMode: 渲染效果
    /// - Returns: CAEmitterLayer
    func _renderMode(_ renderMode: CAEmitterLayerRenderMode?) -> CAEmitterLayer {
        if let renderMode = renderMode { self.renderMode = renderMode }         // 渲染效果
        return self
    }
    
    /// 設定時間間隔
    /// - Parameter offset: 時間間隔
    /// - Returns: CAEmitterLayer
    func _timeOffset(offset: CFTimeInterval?) -> CAEmitterLayer {
        if let offset = offset { self.beginTime = CACurrentMediaTime(); self.timeOffset = offset }
        return self
    }
}

// MARK: - CAEmitterCell (static function)
extension CAEmitterCell {

    enum EmitterCellType {
        case snowFlake
        case firework
    }
    
    /// 各式EmitterCell產生器
    /// - Parameters:
    ///   - type: 樣式
    ///   - image: 圖片
    ///   - birthRate: 產生數量
    ///   - lifetime: 存活時間
    ///   - color: 顏色
    /// - Returns: CAEmitterCell
    static func _maker(for type: EmitterCellType, image: UIImage, birthRate: Float = 1, lifetime: Float = 10.0, color: UIColor? = nil) -> CAEmitterCell {
        
        switch type {
        case .snowFlake: return _snowFlakeCell(image: image, birthRate: birthRate, lifetime: lifetime, color: color)
        case .firework: return _fireworkCell(image: image, birthRate: birthRate, lifetime: lifetime, color: color)
        }
    }
}

// MARK: - CAEmitterCell (private static function)
extension CAEmitterCell {
    
    /// [雪花Cell產生器](https://medium.com/@satindersingh71/smooth-core-animation-snow-effect-3d93417b96b3)
    /// - Parameters:
    ///   - image: 雪花圖片
    ///   - birthRate: 產生數量
    ///   - lifetime: 存活時間
    ///   - color: 顏色
    /// - Returns: CAEmitterCell
    private static func _snowFlakeCell(image: UIImage, birthRate: Float, lifetime: Float, color: UIColor? = nil) -> CAEmitterCell {
        
        let cell = CAEmitterCell()._setting(image: image, birthRate: birthRate, lifetime: lifetime)
                                  ._scale(1.0, range: 0.3, speed: -0.02)
                                  ._acceleration(x: 5, y: 30)
                                  ._velocity(-30, range: -20)
                                  ._emission(range: .pi, latitude: .pi, longitude: .pi)
                                  ._spin(-0.5, range: 1.0)
                                  ._color(color, redRange: 0, greenRange: 0, blueRange: 0)
        return cell
    }
    
    /// [煙火Cell產生器](https://medium.com/@peteliev/what-do-you-know-about-caemitterlayer-368378d45c2e)
    /// - Parameters:
    ///   - image: 煙火圖片
    ///   - birthRate: 產生數量
    ///   - lifetime: 存活時間
    ///   - color: color description
    /// - Returns: CAEmitterCell
    private static func _fireworkCell(image: UIImage, birthRate: Float, lifetime: Float, color: UIColor? = nil) -> CAEmitterCell {
        
        let emitterCell = _fireworkEmitterCell(birthRate: birthRate, lifetime: lifetime, color: color)
        let trailCell = _fireworkTrailCell(image: image)
        let fireworkCell = _fireworkMainCell(image: image)
        
        emitterCell.emitterCells = [trailCell, fireworkCell]
        
        return emitterCell
    }
    
    /// 煙火Cell容器產生器
    /// - Parameters:
    ///   - birthRate: 產生數量
    ///   - lifetime: 存活時間
    ///   - color: 顏色
    /// - Returns: CAEmitterCell
    private static func _fireworkEmitterCell(birthRate: Float, lifetime: Float, color: UIColor?) -> CAEmitterCell {
        
        let cell = CAEmitterCell()._setting(birthRate: birthRate, lifetime: lifetime)
                                  ._color(color, redRange: 0.9, greenRange: 0.9, blueRange: 0.9)
                                  ._velocity(-300, range: -100)
                                  ._acceleration(x: 0, y: -100)
                                  ._emission(range: CGFloat.pi / 4, latitude: 0, longitude: CGFloat.pi / 2)
                
        return cell
    }
    
    /// 煙火尾巴產生器
    /// - Parameter image: 圖片
    /// - Returns: CAEmitterCell
    private static func _fireworkTrailCell(image: UIImage) -> CAEmitterCell {
        
        let cell = CAEmitterCell()._setting(image: image, birthRate: 45.0, lifetime: 0.5)
                                  ._scale(0.4, range: 0.1, speed: -0.1)
                                  ._acceleration(x: 0, y: 350)
                                  ._velocity(-80, range: 0)
                                  ._emission(range: CGFloat.pi / 8, latitude: 0, longitude: CGFloat.pi * 2)
                                  ._alpha(range: 0, speed: -0.7)
                                  ._duration(1.7, beginTime: 0.01)
        return cell
    }
    
    /// 主要煙火產生器
    /// - Parameter image: 圖片
    /// - Returns: CAEmitterCell
    private static func _fireworkMainCell(image: UIImage) -> CAEmitterCell {
        
        let cell = CAEmitterCell()._setting(image: image, birthRate: 10000, lifetime: 100)
                                  ._scale(0.6, range: 0, speed: -0.1)
                                  ._velocity(-130, range: 0)
                                  ._acceleration(x: 0, y: 80)
                                  ._spin(2, range: 0)._alpha(range: 0, speed: -0.2)
                                  ._emission(range: CGFloat.pi * 2, latitude: 0, longitude: 0)
                                  ._duration(0.1, beginTime: 1.5)
                
        return cell
    }
}

// MARK: - CAEmitterCell (class function)
extension CAEmitterCell {
    
    /// 基本設定
    /// - Parameters:
    ///   - image: Cell的長相
    ///   - birthRate: 個數 (1/s)
    ///   - lifetime: 存活時間 (s)
    /// - Returns: CAEmitterCell
    func _setting(image: UIImage? = nil, birthRate: Float, lifetime: Float) -> CAEmitterCell {
        
        if let image = image { self.contents = image.cgImage }
        
        self.birthRate = birthRate
        self.lifetime = lifetime

        return self
    }
    
    /// 設定縮放大小
    /// - Parameters:
    ///   - scale: 基本大小倍數 => 0.06
    ///   - range: 倍數大小範圍 => (0.06 - 0.3) ~ (0.06 + 0.3)
    ///   - speed: 大小改變的速度 => -0.02 => 越變越小
    /// - Returns: CAEmitterCell
    func _scale(_ scale: CGFloat, range: CGFloat, speed: CGFloat) -> CAEmitterCell {
        
        self.scale = scale
        self.scaleRange = range
        self.scaleSpeed = speed
        
        return self
    }
    
    /// 設定速度
    /// - Parameters:
    ///   - velocity: 基本速度 => -30
    ///   - range: 速度範圍 => (-30 - 20) ~ (-50 + -20)
    /// - Returns: CAEmitterCell
    func _velocity(_ velocity: CGFloat, range: CGFloat) -> CAEmitterCell {
        
        self.velocity = velocity
        self.velocityRange = range
        
        return self
    }
    
    /// 設定加速度
    /// - Parameters:
    ///   - x: 左右移動的加速度
    ///   - y: 上下移動的加速度
    /// - Returns: CAEmitterCell
    func _acceleration(x: CGFloat, y: CGFloat) -> CAEmitterCell {
        
        self.xAcceleration = x
        self.yAcceleration = y

        return self
    }
    
    /// 設定週期
    /// - Parameters:
    ///   - duration: 週期
    ///   - beginTime: 開始時間
    /// - Returns: CAEmitterCell
    func _duration(_ duration: CFTimeInterval, beginTime: CFTimeInterval) -> CAEmitterCell {
        
        self.beginTime = beginTime
        self.duration = duration
        
        return self
    }
    
    /// 旋轉速度
    /// - Parameters:
    ///   - spin: 旋轉速度 (radians)
    ///   - range: 旋轉速度範圍 => (-0.5 - 1.0) ~ (-0.5 + 1.0)
    /// - Returns: CAEmitterCell
    func _spin(_ spin: CGFloat, range: CGFloat) -> CAEmitterCell {
        
        self.spin = spin
        self.spinRange = range

        return self
    }
    
    /// 設定角度
    /// - Parameters:
    ///   - range: 發射的角度範圍 => 不會單純只是直直的落下
    ///   - latitude: XY平面的發射角度
    ///   - longitude: Z軸方向的發射角度
    /// - Returns: CAEmitterCell
    func _emission(range: CGFloat, latitude: CGFloat, longitude: CGFloat) -> CAEmitterCell {
        
        self.emissionRange = range
        self.emissionLatitude = latitude
        self.emissionLongitude = longitude
        
        return self
    }
    
    /// 設定顏色
    /// - Parameters:
    ///   - color: 顯示的顏色
    ///   - redRange: 顏色的變化範圍 (紅)
    ///   - greenRange: 顏色的變化範圍 (綠)
    ///   - blueRange: 顏色的變化範圍 (監)
    /// - Returns: CAEmitterCell
    func _color(_ color: UIColor? = nil, redRange: Float, greenRange: Float, blueRange: Float) -> CAEmitterCell {
        
        if let color = color { self.color = color.cgColor }
        
        self.redRange = redRange
        self.greenRange = greenRange
        self.blueRange = blueRange
        
        return self
    }
    
    /// 設定透明度
    /// - Parameters:
    ///   - range: 隨機透明度範圍 => 0.75
    ///   - speed: 透明度改變的速度 => -0.15 => 越變越透明
    /// - Returns: CAEmitterCell
    func _alpha(range: Float, speed: Float) -> CAEmitterCell {
        
        self.alphaRange = range
        self.alphaSpeed = speed
        
        return self
    }
}
