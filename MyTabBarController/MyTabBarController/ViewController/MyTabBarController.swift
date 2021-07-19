//
//  MyTabBarController.swift
//  MyTabBarController
//
//  Created by William.Weng on 2021/6/7.
//

import UIKit

// MARK: - 自訂UITabBarController背景
final class MyTabBarController: UITabBarController {

    private let stackView = UIStackView()
    private let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        initStackView()
        initTabbarViews()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        notificationCenter._post(name: ._tabbarDidSelected, object: item)
    }
}

// MARK: - 小工具
extension MyTabBarController {
    
    /// 初始化StackView => 到最底層 (index = 0)
    private func initStackView() {
        
        stackView._constraint(on: self.tabBar)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        tabBar.insertSubview(stackView, at: .zero)
    }
    
    /// 初始化Tabbar的背景 (只有一次)
    private func initTabbarViews() {
        
        notificationCenter._register(name: ._tabbarStackViews) { notification in
            
            guard let views = notification.object as? [UIView] else { return }
            
            self.stackView._addArrangedSubviews(views)
            self.notificationCenter._remove(observer: self, name: ._tabbarStackViews)
        }
    }
}
