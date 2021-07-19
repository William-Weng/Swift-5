//
//  ViewController.swift
//  FloatingViewDemo
//
//  Created by William.Weng on 2020/11/10.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    override func viewDidLoad() { super.viewDidLoad() }
    deinit { wwPrint("deinit") }
}

// MARK: - 小工具
extension ViewController {
    
    /// 顯示FloatingView
    @IBAction func showFloatingViewController(_ sender: UIButton) {
        
        let viewController = FloatingViewController()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "demo"))
        
        viewController.myDelegate = self
        viewController.configure(currentView: imageView)
        
        imageView.contentMode = .scaleAspectFit

        present(viewController, animated: true) {
            guard let imageView = viewController.currentView as? UIImageView else { return }
            imageView.backgroundColor = .systemPink
        }
    }
}

// MARK: - FloatingViewDelegate
extension ViewController: FloatingViewDelegate {
    
    func willAppear(completePercent: CGFloat) {
        wwPrint(completePercent)
    }
    
    func appearing(fractionComplete: CGFloat) {
        wwPrint(fractionComplete)
    }
    
    func didAppear(animatingPosition: UIViewAnimatingPosition) {
        print(animatingPosition: animatingPosition, title: "出現啦")
    }
    
    func didDisAppear(animatingPosition: UIViewAnimatingPosition) {
        print(animatingPosition: animatingPosition, title: "消失了")
    }
}

// MARK: - 小工具
extension ViewController {
    
    private func print(animatingPosition: UIViewAnimatingPosition, title: String) {
        
        switch animatingPosition {
        case .start: wwPrint("start => \(title)")
        case .current: wwPrint("current => \(title)")
        case .end: wwPrint("end => \(title)")
        @unknown default: fatalError()
        }
    }
}
