//
//  MySplitViewController.swift
//  UISplitViewController_HelloWorld
//
//  Created by William.Weng on 2020/10/6.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

final class MySplitViewController: UISplitViewController, StatusBarHideable {

    var isStatusBarHidden = false { didSet { setNeedsStatusBarAppearanceUpdate() } }
    
    override var prefersStatusBarHidden: Bool { return isStatusBarHidden }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        primaryColumnWidthSetting()
    }
}

// MARK: - 小工具
extension MySplitViewController {
    
    /// 設定選單的寬度
    private func primaryColumnWidthSetting() {
        minimumPrimaryColumnWidth = 512
        maximumPrimaryColumnWidth = 768
    }
}
