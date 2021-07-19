//
//  FloatingViewController.swift
//  FloatingViewDemo
//
//  Created by William.Weng on 2020/11/10.
//  Copyright © 2020 William.Weng. All rights reserved.
//
/// [Swift — 簡單動手做一個懸浮拖曳視窗](https://medium.com/jeremy-xue-s-blog/swift-簡單動手做一個懸浮拖曳視窗-33ce429ca0f2)
/// [DAY16 UIGestureRecognizer - iT 邦幫忙::一起幫忙解決難題，拯救 IT 人的一天](https://ithelp.ithome.com.tw/articles/10205703?sc=iThelpR)
/// [iOS手勢-UIPanGestureRecognizer](https://www.jianshu.com/p/33e8dab5d11b)

import UIKit

// MARK: - FloatingViewDelegate
protocol FloatingViewDelegate: class {
    
    /// 將要顯示 - 沒出現
    func willAppear(completePercent: CGFloat)
    
    /// 出現中
    func appearing(fractionComplete: CGFloat)
    
    /// 顯示完成 - 出現了
    func didAppear(animatingPosition: UIViewAnimatingPosition)
    
    /// 顯示結束 - 不見了
    func didDisAppear(animatingPosition: UIViewAnimatingPosition)
}

// MARK: - FloatingViewController
final class FloatingViewController: UIViewController {

    @IBOutlet weak var floatingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var floatingView: UIView!
    
    var currentView: UIView?
    weak var myDelegate: FloatingViewDelegate?
    
    private var animationDuration: TimeInterval = 0.5
    private var floatingViewCornerRadius: CGFloat = 8.0
    private var completePercent: CGFloat = 0.5
    private var propertyAnimator: UIViewPropertyAnimator!
    
    override func viewDidLoad() { super.viewDidLoad(); initSetting() }
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); showFloatingView(duration: animationDuration) }
    
    deinit { wwPrint("deinit") }
}

// MARK: - 參數設定
extension FloatingViewController {
    
    /// 參數設定
    func configure(animationDuration: TimeInterval = 0.5, floatingViewCornerRadius: CGFloat = 8.0, backgroundColor: UIColor = UIColor(white: 0, alpha: 0.8), completePercent: CGFloat = 0.5, currentView: UIView? = nil) {
        
        self.animationDuration = animationDuration
        self.floatingViewCornerRadius = floatingViewCornerRadius
        self.currentView = currentView
        self.completePercent = completePercent
        self._transparent(backgroundColor)
    }
}

// MARK: - @objc
extension FloatingViewController {
    
    /// 退出ViewController
    /// - 點下之後退出
    @objc private func dissmissViewController(_ recognizer: UITapGestureRecognizer) { dismiss(animated: true, completion: nil) }
    
    @objc private func floatingViewAnimation(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began: floatingViewPanBegan(recognizer, duration: animationDuration)
        case .changed: floatingViewPanChanged(recognizer)
        case .ended: floatingViewPanEnded(recognizer, completePercent: completePercent)
        default: break
        }
    }
}

// MARK: - 小工具
extension FloatingViewController {
    
    /// 初始化設定
    private func initSetting() {
        initFloatingViewSetting()
        currentViewSetting()
        floatingViewSetting(cornerRadius: floatingViewCornerRadius)
    }
    
    /// 初始化設定floatingView
    /// - 將FloatingView移出畫面外
    private func initFloatingViewSetting() {
        
        let recognizer = UIPanGestureRecognizer._build(target: self, action: #selector(floatingViewAnimation(_:)))
        
        floatingView.transform = CGAffineTransform(translationX: 0, y: floatingView.bounds.height)
        floatingView.isUserInteractionEnabled = true
        floatingView.addGestureRecognizer(recognizer)
    }
    
    /// 加上自訂的View
    private func currentViewSetting() {
        
        guard let currentView = currentView else { return }
        currentView._constraint(on: floatingView)._end()
    }
    
    /// floatingView外型的圓角設定
    private func floatingViewSetting(cornerRadius: CGFloat) { floatingView.layer._maskedCorners(radius: cornerRadius, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner]) }
    
    /// 顯示FloatingView
    /// - 包含動畫
    private func showFloatingView(duration: TimeInterval) {
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
            self.floatingView.transform = .identity
            self.myDelegate?.willAppear(completePercent: 0)
        }, completion: { (animatingPosition) in
            self.myDelegate?.didAppear(animatingPosition: animatingPosition)
        })
    }
    
    /// 拖曳開始
    /// - 創建animator
    /// - 裡面的值為「最後的結果」
    private func floatingViewPanBegan(_ recognizer: UIPanGestureRecognizer, duration: TimeInterval) {
        
        propertyAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            self.floatingView.transform = CGAffineTransform(translationX: 0, y: self.floatingView.bounds.height)
            self.view.backgroundColor = .clear
        }
    }
    
    /// 拖曳改變時
    /// - 取得動畫的進行百分比 => fractionComplete => run
    private func floatingViewPanChanged(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: floatingView)
        let fractionComplete = translation.y / floatingView.bounds.height
        
        propertyAnimator.fractionComplete = fractionComplete
        
        self.myDelegate?.appearing(fractionComplete:  propertyAnimator.fractionComplete)
    }
    
    /// 拖曳結束時
    /// - 完成百分比 <= 50% => 彈回去 (反轉動畫)
    /// - 完成百分比 > 50% => 加上結束動畫
    /// - 不管結果如何，動畫都繼續
    private func floatingViewPanEnded(_ recognizer: UIPanGestureRecognizer, completePercent: CGFloat = 0.5) {
        
        defer { propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
        
        guard propertyAnimator.fractionComplete > completePercent else { propertyAnimator.isReversed = true; return }
        
        propertyAnimator.addCompletion { (animatingPosition) in
            self.dismiss(animated: true, completion: {
                self.myDelegate?.didDisAppear(animatingPosition: animatingPosition)
            })
        }
    }
}
