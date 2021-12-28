//
//  SubView.swift
//  Example
//
//  Created by William.Weng on 2021/12/28.
//

import UIKit
import WWPrint

// MARK: - 動態的進度條
class SubView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
    override init(frame: CGRect) { super.init(frame: frame); initViewFromXib(); wwPrint("") }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initViewFromXib(); wwPrint("") }
    
    override func willMove(toWindow newWindow: UIWindow?) { super.willMove(toWindow: newWindow); wwPrint("") }
    override func willMove(toSuperview newSuperview: UIView?) { super.willMove(toSuperview: newSuperview); wwPrint("") }
    
    override func removeFromSuperview() { super.removeFromSuperview(); wwPrint("") }
    override func willRemoveSubview(_ subview: UIView) { super.willRemoveSubview(subview); wwPrint("") }

    override func didMoveToSuperview() { super.didMoveToSuperview(); wwPrint("") }
    override func didMoveToWindow() { super.didMoveToWindow(); wwPrint("") }
    
    override func updateConstraints() { super.updateConstraints(); wwPrint("") }
    
    override func layerWillDraw(_ layer: CALayer) { super.layerWillDraw(layer); wwPrint("") }
    
    override func draw(_ rect: CGRect) { super.draw(rect); wwPrint("") }
    override func draw(_ layer: CALayer, in ctx: CGContext) { super.draw(layer, in: ctx); wwPrint("") }
    
    override func didAddSubview(_ subview: UIView) { super.didAddSubview(subview); wwPrint("") }
    
    deinit { wwPrint("") }
}

// MARK: - 小工具
extension SubView {
    
    /// 讀取Nib畫面 => 加到View上面
    private func initViewFromXib() {
        
        let bundle = Bundle.main
        let name = String(describing: Self.self)
        
        bundle.loadNibNamed(name, owner: self, options: nil)
        contentView.frame = bounds
        
        addSubview(contentView)
    }
}
