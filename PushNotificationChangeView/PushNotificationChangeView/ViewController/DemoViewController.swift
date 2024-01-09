//
//  DemoViewController.swift
//  PushNotificationChangeView
//
//  Created by William.Weng on 2024/1/9.
//

import UIKit
import WWPrint

final class DemoViewController: UIViewController {

    @IBOutlet weak var staffLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!

    var dismissButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    /// 把自己關掉
    /// - Parameter sender: UIBarButtonItem
    @IBAction func dissmissAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true) { self.navigationController?.viewControllers = [] }
    }
}

// MARK: - 小工具
private extension DemoViewController {
    
    /// 初始化設定
    /// => 第一頁能把自己關掉
    func initSetting() {
        
        guard let navigationController = navigationController else { return }
        
        if (navigationController.viewControllers.count == 1) {
            dismissButtonItem = UIBarButtonItem(title: "✖", style: .plain, target: self, action: #selector(self.dissmissAction(_:)))
            navigationItem.leftBarButtonItems = [dismissButtonItem]
        }
    }
}
