//
//  ProgressView.swift
//  WWProgressView
//
//  Created by William.Weng on 2021/11/12.
//

import UIKit
import WWPrint

protocol ProgressViewDeleagte: AnyObject {
        
    typealias ProgressViewInfomation = (text: String?, icon: UIImage?)
    
    func valueChange(identifier: String, currentValue: CGFloat, maximumValue: CGFloat) -> ProgressViewInfomation
}

@IBDesignable final class ProgressView: UIView {
    
    public enum ProgressType {
        case continuous
        case segmented(_ count: UInt)
    }
    
    @IBInspectable var identifier: String = "ProgressView"
    @IBInspectable var currentValue: CGFloat = 0
    @IBInspectable var labelPosition: CGFloat = 0
    @IBInspectable var iconPosition: CGFloat = 0
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var progressColor: UIColor = .clear
    @IBInspectable var borderColor: UIColor = .clear

    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconPositionConstraint: NSLayoutConstraint!

    @IBOutlet var contentView: UIView!

    public weak var myDeleagte: ProgressViewDeleagte?
    
    private var touchPoint: (start: CGPoint?, constant: CGFloat) = (nil, 0)
    private var progressType: ProgressType = .continuous

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromXib()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewFromXib()
    }
    
    override public func draw(_ rect: CGRect) { redrawOnStoryboard() }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { recordStartTouchPoint(touches, with: event) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { updateHeightConstraint(touches, with: event) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { touchPoint.start = nil }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}

// MARK: - 公開的
extension ProgressView {
    
    /// 設定一些初始的文字及圖示
    /// - Parameters:
    ///   - id: 辨識字
    ///   - initValue: 上方的Label文字
    ///   - font: Label字型
    ///   - icon: 下方的圖示
    ///   - type: 滑動的模式 (連續顯示 / 一段一段顯示)
    public func configure(id: String, initValue: String?, font: UIFont? = .systemFont(ofSize: 36.0), icon: UIImage? = nil, type: ProgressType = .continuous) {
        
        identifier = id
        progressType = type
        
        displayLabel.font = font
        displayLabel.text = initValue
        displayImageView.image = icon
    }
}

// MARK: - 小工具
extension ProgressView {
    
    /// 讀取Nib畫面 => 加到View上面
    private func initViewFromXib() {
        
        let bundle = Bundle.init(for: ProgressView.self)
        let name = String(describing: ProgressView.self)
        
        bundle.loadNibNamed(name, owner: self, options: nil)
        contentView.frame = bounds
        
        addSubview(contentView)
    }
    
    /// 初始化參數設定
    private func initSetting() {
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        
        progressView.backgroundColor = progressColor
        touchPoint.constant = safeTouchPointConstant(currentValue)
        heightConstraint.constant = touchPoint.constant
        iconPositionConstraint.constant = iconPosition
        labelPositionConstraint.constant = labelPosition
    }
    
    /// 及時畫面重繪 => @IBDesignable
    private func redrawOnStoryboard() {

        initSetting()
        
        #if TARGET_INTERFACE_BUILDER
        #endif
    }
    
    /// 記錄點擊的起點位置
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: UIEvent?
    private func recordStartTouchPoint(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchPoint.start = touch.location(in: self)
    }
    
    /// 更新高度Constraint (range: min~max)
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: UIEvent?
    private func updateHeightConstraint(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let startTouchPoint = touchPoint.start,
              let endTouchPoint = touches.first?.location(in: self)
        else {
            return
        }
        
        touchPoint.start = endTouchPoint
        touchPoint.constant += startTouchPoint.y - endTouchPoint.y
        touchPoint.constant = safeTouchPointConstant(touchPoint.constant)
                
        heightConstraint.constant = safeHeightConstraint(touchPoint.constant, progressType: progressType)
        valueChangeAction(heightConstraint.constant)
    }
    
    /// 設定數值的安全大小範圍 (記錄的高度) => 0 ~ 最大高度
    /// - Parameter touchPointConstant: CGFloat
    /// - Returns: CGFloat
    private func safeTouchPointConstant(_ touchPointConstant: CGFloat) -> CGFloat {
        
        if (touchPointConstant > contentView.frame.height) { return contentView.frame.height }
        if (touchPointConstant < 0) { return 0 }
        
        return touchPointConstant
    }
    
    /// 設定數值的安全大小範圍 (顯示的高度) => 0 ~ 最大高度
    /// - Parameter touchPointConstant: CGFloat
    /// - Returns: CGFloat
    private func safeHeightConstraint(_ touchPointConstant: CGFloat, progressType: ProgressType) -> CGFloat {
        
        let _touchPointConstant = safeTouchPointConstant(touchPointConstant)
        
        switch progressType {
        case .continuous: return _touchPointConstant
        case .segmented(let count): return segmentedHeightConstraint(count, touchPointConstant: touchPointConstant)
        }
    }
    
    /// 數值改變時的反應
    /// - Parameter value: CGFloat?
    private func valueChangeAction(_ value: CGFloat) {
        
        guard let info = myDeleagte?.valueChange(identifier: identifier, currentValue: value, maximumValue: contentView.frame.height) else { return }
        
        displayLabel.text = info.text
        displayImageView.image = info.icon
    }
    
    /// 產生出分段的高度Constraint (一格一格的)
    /// - Parameter count: UInt
    /// - Parameter touchPointConstant: 真正的所點的高度
    /// - Returns: CGFloat?
    private func segmentedHeightConstraint(_ count: UInt, touchPointConstant: CGFloat) -> CGFloat {
        
        let index = Int(touchPointConstant * CGFloat(count) / contentView.frame.height)
        let result = contentView.frame.height * CGFloat(index) / CGFloat(count)
                
        return result
    }
}
