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
    
    func valueChange(_ currentValue: CGFloat, maximumValue: CGFloat) -> ProgressViewInfomation
}

@IBDesignable final class ProgressView: UIView {
    
    @IBInspectable var currentValue: CGFloat = 0
    @IBInspectable var labelPosition: CGFloat = 0
    @IBInspectable var iconPosition: CGFloat = 0
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var borderColor: UIColor = .clear

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconPositionConstraint: NSLayoutConstraint!

    @IBOutlet var contentView: UIView!

    public weak var myDeleagte: ProgressViewDeleagte?
    
    private var startTouchPoint: CGPoint?
    
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
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { startTouchPoint = nil }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}

// MARK: - 公開的
extension ProgressView {
    
    /// 設定一些初始的文字及圖示
    /// - Parameters:
    ///   - initValue: String?
    ///   - font: UIFont?
    public func configure(initValue: String?, font: UIFont? = .systemFont(ofSize: 36.0), icon: UIImage? = nil) {
        
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
        
        heightConstraint.constant = currentValue
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
        startTouchPoint = touch.location(in: self)
    }
    
    /// 更新高度Constraint
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: UIEvent?
    private func updateHeightConstraint(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let startTouchPoint = startTouchPoint,
              let endTouchPoint = touches.first?.location(in: self)
        else {
            return
        }
        
        heightConstraint.constant += startTouchPoint.y - endTouchPoint.y
        self.startTouchPoint = endTouchPoint
        
        if (heightConstraint.constant > contentView.frame.height) { heightConstraint.constant = contentView.frame.height }
        if (heightConstraint.constant < 0) { heightConstraint.constant = 0 }

        valueChangeAction(heightConstraint.constant)
    }
    
    /// 數值改變時的反應
    /// - Parameter value: CGFloat?
    private func valueChangeAction(_ value: CGFloat) {
        
        guard let info = myDeleagte?.valueChange(value, maximumValue: contentView.frame.height) else { return }
        
        displayLabel.text = info.text
        displayImageView.image = info.icon
    }
}
