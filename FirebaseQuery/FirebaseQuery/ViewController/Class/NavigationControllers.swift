//
//  _BaseNavigationController.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/13.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

// MARK: - 基礎的NavigationController
class _BaseNavigationController: UINavigationController {
    
    var newType: TabBarType = .cart
    var newTitle: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting(type: newType, title: newTitle)
    }
}

// MARK: - 小工具
extension _BaseNavigationController {
    
    /// 設定基本變數
    fileprivate func configure(type: TabBarType, title: String) {
        newType = type
        newTitle = title
    }
    
    /// 設定下一個ViewController的初始型態
    private func initSetting(type: TabBarType, title: String) {
        let viewController = viewControllers.first as? ProductActionViewController
        viewController?.tabBarType = type
        viewController?.navigationItemTitle = title
    }
}

// MARK: - StockNavigationController
class StockNavigationController: _BaseNavigationController {
    
    override func viewDidLoad() {
        configure(type: .cart, title: "新品")
        super.viewDidLoad()
    }
}

// MARK: - PlusNavigationController
class PlusNavigationController: _BaseNavigationController {
    
    override func viewDidLoad() {
        configure(type: .plus, title: "進貨")
        super.viewDidLoad()
    }
}
// MARK: - MinusNavigationController
class MinusNavigationController: _BaseNavigationController {
    
    override func viewDidLoad() {
        configure(type: .minus, title: "出貨")
        super.viewDidLoad()
    }
}

// MARK: - FixNavigationController
class FixNavigationController: _BaseNavigationController {
    
    override func viewDidLoad() {
        configure(type: .fix, title: "更新")
        super.viewDidLoad()
    }
}
