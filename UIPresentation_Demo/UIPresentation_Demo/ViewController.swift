//
//  ViewController.swift
//  UIPresentation_Demo
//
//  Created by William.Weng on 2020/2/12.
//  Copyright © 2020 William.Weng. All rights reserved.
//
/// [用UIPresentationController來寫一個簡潔漂亮的底部彈出控件](https://juejin.im/post/5a9651d25188257a5911f666)

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func showCustomAlert(_ sender: UIButton) {
        presentBottomController(PresentBottomViewController())
    }

    /// 退出PresentationController
    @objc private func dismissViewController(_ recognizer: UITapGestureRecognizer) {
        recognizer.view?.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 跳出PresentationController
    private func presentBottomController(_ controller: UIViewController) {
        
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self

        present(controller, animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let presentingViewController = MyPresentationController(presentedViewController: presented, presenting: presenting)
        
        presentingViewController.controllerHeight = 200
        presentingViewController.gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissViewController(_:)))
        
        return presentingViewController
    }
}

/// 要跳轉的ViewController
class PresentBottomViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}

// MARK: - 自定義的過場動畫Controller (UIViewControllerTransitioningDelegate)
/// viewController.modalPresentationStyle = .custom
/// viewController.transitioningDelegate = self
/// present(viewController, animated: true, completion: nil))
class MyPresentationController: UIPresentationController {
    
    var controllerHeight = UIScreen.main.bounds.height
    var gestureRecognizer = UIGestureRecognizer()
    var backgroundColor = UIColor.black.withAlphaComponent(0.5)
    
    lazy var blackView = backgroundView(with: backgroundColor)
    
    override var frameOfPresentedViewInContainerView: CGRect { return presentedViewFrame() }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() { presentationTransitionWillBeginSetting() }
    override func dismissalTransitionWillBegin() { dismissalTransitionWillBeginSetting() }
    override func presentationTransitionDidEnd(_ completed: Bool) {}
    override func dismissalTransitionDidEnd(_ completed: Bool) {}
    
    deinit { print("MyPresentationController deinit") }
}

// MARK: - 小工具
extension MyPresentationController {
    
    /// 開始進入時的設定 (加入BlackView + 動畫)
    private func presentationTransitionWillBeginSetting() {
        
        guard let blackView = blackView,
              let containerView = containerView
        else {
            return
        }

        containerView.addSubview(blackView)
        blackViewActionSetting(recognizer: gestureRecognizer)
        
        blackView.alpha = 0.0
        UIView.animate(withDuration: 0.5) { blackView.alpha = 1.0 }
    }
    
    /// 開始退出時的設定 (移除BlackView + 動畫)
    private func dismissalTransitionWillBeginSetting() {
        guard let blackView = blackView else { return }
        UIView.animate(withDuration: 0.5) { blackView.alpha = 0.0 }
    }
    
    /// 產生一個背景View
    private func backgroundView(with color: UIColor) -> UIView? {
        
        guard let bounds = containerView?.bounds,
              let view = Optional.some(UIView())
        else {
            return nil
        }
        
        view.frame = bounds
        view.backgroundColor = color
        
        return view
    }
    
    /// 彈出的View的位置跟大小
    private func presentedViewFrame() -> CGRect {
        
        let origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - controllerHeight)
        let size = CGSize(width: UIScreen.main.bounds.width, height: controllerHeight)
        
        return CGRect(origin: origin, size: size)
    }

    /// 點擊背景View時候的動作
    private func blackViewActionSetting(recognizer: UIGestureRecognizer) {
        guard let blackView = blackView else { return }
        blackView.addGestureRecognizer(recognizer)
    }
}
