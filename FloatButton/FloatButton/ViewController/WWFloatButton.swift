//
//  WWFloatButton.swift
//  Example
//
//  Created by William.Weng on 2022/12/20.
//

import UIKit
import WWPrint

protocol WWFloatButtonDelegate {
    
    func currentView(with tag: Int) -> UIView
    func mainButtonStatus(isTouched: Bool, with tag: Int)
    func itemButton(with tag: Int, didTouched index: Int)
    func itemButtonImages(with tag: Int) -> [UIImage]
}

open class WWFloatButton: UIView {
    
    @IBInspectable var itemButtonCount: Int = 1
    @IBInspectable var itemGap: CGFloat = 10
    @IBInspectable var animationDuration: CGFloat = 0.5
    @IBInspectable var itemBackgroundColor: UIColor = .gray.withAlphaComponent(0.3)
    @IBInspectable var touchedImage: UIImage = UIImage()
    @IBInspectable var disableImage: UIImage = UIImage()

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainButton: UIButton!
    
    var myDelegate: WWFloatButtonDelegate?
    
    private var isTouched = false
    private var floatSubButtonView: UIView = UIView()
    private var itemButtons: [UIButton] = []
    
    private var currentView: UIView? { get { myDelegate?.currentView(with: tag) }}
    private var itemImages: [UIImage]? { get { myDelegate?.itemButtonImages(with: tag) }}
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromXib()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewFromXib()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        initSetting()
    }
        
    @objc func itemButtonAction(_ sender: UIButton) {
        toggleFloatButton { self.myDelegate?.itemButton(with: self.tag, didTouched: sender.tag) }
    }

    @IBAction func mainButtonAction(_ sender: UIButton) {
        toggleFloatButton(action: {})
    }
}

// MARK: - 小工具
private extension WWFloatButton {
    
    /// 讀取Nib畫面 => 加到View上面
    func initViewFromXib() {

        let bundle = Bundle(for: Self.self)
        let name = String(describing: Self.self)
        bundle.loadNibNamed(name, owner: self, options: nil)

        contentView.frame = bounds
        addSubview(contentView)
    }
    
    /// 切始化
    func initSetting() {
        
        guard let currentView = self.currentView else { return }
        
        mainButton.setImage(disableImage, for: .normal)
        
        floatSubButtonView = UIView(frame: currentView.frame)
        floatSubButtonView.isUserInteractionEnabled = false
        floatSubButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.mainButtonAction(_:))))
        floatSubButtonView.backgroundColor = itemBackgroundColor
        
        currentView.insertSubview(floatSubButtonView, at: 0)
        
        initItemButton()
        myDelegate?.mainButtonStatus(isTouched: isTouched, with: tag)
    }
    
    /// 切始化ItemButton
    func initItemButton() {
        
        guard let itemImages = itemImages else { return }
        
        for index in 0..<itemButtonCount {
            let _button = itemButtonMaker(with: index, image: itemImages[safe: index])
            itemButtons.append(_button)
            floatSubButtonView.addSubview(_button)
        }
    }
    
    /// 建立ItemButton
    /// - Parameters:
    ///   - index: Int
    ///   - image:  UIImage?
    /// - Returns: UIButton
    func itemButtonMaker(with index: Int, image: UIImage?) -> UIButton {
        
        let _button = UIButton(frame: CGRect(origin: .zero, size: bounds.size))
                
        _button.backgroundColor = .yellow
        _button.layer._maskedCorners(radius: _button.frame.height * 0.5)
        _button.isUserInteractionEnabled = false
        _button.tag = Int(index)
        _button.setImage(image, for: .normal)
        _button.center = self.center
        
        _button.addTarget(self, action: #selector(Self.itemButtonAction(_:)), for: .touchUpInside)
        
        return _button
    }
    
    /// 切換Button能不能被按
    /// - Parameter isEnabled: Bool
    func userInteractionEnabled(_ isEnabled: Bool) {

        mainButton.isUserInteractionEnabled = isEnabled
        floatSubButtonView.isUserInteractionEnabled = isEnabled
        
        itemButtons.forEach { _button in
            _button.isUserInteractionEnabled = isEnabled
        }
    }
    
    /// 開關動畫
    /// - Parameters:
    ///   - buttons: [UIButton]
    ///   - isTouched: Bool
    ///   - finished: (Bool) -> Void
    func itemButtonAnimation(with buttons: [UIButton], isTouched: Bool, finished: @escaping (Bool) -> Void) {
        
        guard let currentView = self.currentView else { return }

        self.userInteractionEnabled(false)
        
        if (!isTouched) {
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
                
                buttons.forEach { _button in _button.center = self.center }
                
            }, completion: { (animatingPosition) in
                currentView.sendSubviewToBack(self.floatSubButtonView)
                currentView.bringSubviewToFront(self)
                self.mainButton.isUserInteractionEnabled = true
                finished(true)
            })
            
            return
        }

        currentView.bringSubviewToFront(floatSubButtonView)
        currentView.bringSubviewToFront(self)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            
            let baseOrigin = self.frame.origin
            let baseSize = self.frame.size

            for (index, button) in buttons.enumerated() {
                button.frame = CGRect(origin: CGPoint(x: baseOrigin.x, y: baseOrigin.y - (index + 1)._CGFloat() * (baseSize.height + self.itemGap)), size: baseSize)
            }
            
        }, completion: { (animatingPosition) in
            self.userInteractionEnabled(true)
            finished(true)
        })
    }
    
    /// 切換開關
    func toggleFloatButton(action: (() -> Void)?) {
        isTouched.toggle()
        myDelegate?.mainButtonStatus(isTouched: isTouched, with: tag)
        itemButtonAnimation(with: itemButtons, isTouched: isTouched, finished: { isFinished in
            action?()
        })
    }
}
