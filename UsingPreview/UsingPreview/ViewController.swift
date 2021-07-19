//
//  ViewController.swift
//  UsingPreview
//
//  Created by William.Weng on 2020/1/21.
//  Copyright © 2020 William.Weng. All rights reserved.
//
// [讓 view controller 也能享用 SwiftUI 方便的 preview](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/讓-view-controller-也能享用-swiftui-方便的-preview-314a2e2f0c0f)
// [Xcode Build 配置文件 - xcconfig](https://swift.gg/2019/10/25/nshipster-xcconfig/)

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func changeText(_ sender: UIButton) {
        let alert = Utility.promptAlertController(title: "太好用了啊", message: "還不趕快試試")
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIAlertController相關
final class Utility {
    
    /// 提示AlertController (OK)
    static func promptAlertController(title: String?, message: String?, confirmHandler: (() -> Void)? = nil) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmHandler = UIAlertAction(title: "確定", style: .default) { (_) in if let confirmHandler = confirmHandler { confirmHandler() } }
        
        alertController.addAction(confirmHandler)
        
        return alertController
    }
}
