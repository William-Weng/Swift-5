//
//  AppDelegate.swift
//  MyTabBarController
//
//  Created by William.Weng on 2021/6/7.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var tabbarViews: [UIView] = []
    private var tabBarItemsCount: Int?
    private let notificationCenter = NotificationCenter.default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initTabbarViews()
        tabbarViewsDidSelected()
        return true
    }
}

// MARK: - 小工具
extension AppDelegate {
    
    /// 初始化Tabbar的背景 (只有一次)
    private func initTabbarViews() {
        
        notificationCenter._register(name: ._firstViewControllerDidLoad) { notification in
            
            guard let count = notification.object as? Int else { return }
            
            self.tabbarViews = self.tabbarViewsMaker(with: count)
            
            self.notificationCenter._remove(observer: self, name: ._firstViewControllerDidLoad)
            self.notificationCenter._post(name: ._tabbarStackViews, object: self.tabbarViews)
        }
    }
    
    /// Tabbar被按的處理 => 利用tag來判斷順序
    private func tabbarViewsDidSelected() {
                
        notificationCenter._register(name: ._tabbarDidSelected) { notification in
            
            guard let item = notification.object as? UITabBarItem else { return }
            
            let view = self.tabbarViews[safe: item.tag]
            view?.backgroundColor = ._random()
        }
    }

    // 背景View (可自訂)
    private func tabbarViewsMaker(with count: Int?) -> [UIView] {
        
        var views = [UIView]()
        
        guard let count = count else { return views }
        
        for index in 0..<count {
            
            let view = UIView()

            view.tag = index
            view.backgroundColor = ._random()
            views.append(view)
        }
        
        return views
    }
}
