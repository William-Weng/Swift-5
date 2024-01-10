//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/1/9.
//  ~/Library/Caches/org.swift.swiftpm/

import UIKit
import WWPrint

final class ViewController: UIViewController {

    static let notificationName = "ChangePageWithPushUserInfo"
    
    private var myNavigationController: MyNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 初始化設定
    func initSetting() {
        
        guard let myNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "MyNavigationController") as? MyNavigationController,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        
        myNavigationController._modalStyle(transitionStyle: .coverVertical, presentationStyle: .overCurrentContext)
        myNavigationController.viewControllers = []
        myNavigationController.navigationBar.tintColor = .black
        
        self.myNavigationController = myNavigationController
        registerNotification()
        
        displayProductNameWithUserInfo(appDelegate.userInfo)
    }
    
    /// 顯示獎品名稱
    /// - Parameter userInfo: 推播收到的資訊
    func displayProductNameWithUserInfo(_ userInfo: [AnyHashable: Any]?) {
        
        guard let userInfo = userInfo,
              let staffName = userInfo["staffName"] as? String,
              let productName = userInfo["productName"] as? String
        else {
            return
        }
        
        self.displayProductName(productName, staffName: staffName)
    }
    
    /// 顯示獎品名稱
    /// => 仿蝦皮收到DM推播，一直下一頁顯示
    /// - Parameters:
    ///   - productName: String
    ///   - staffName: String
    func displayProductName(_ productName: String, staffName: String) {
        
        guard let myNavigationController = myNavigationController,
              let demoViewController = self.demoViewController()
        else {
            return
        }
        
        if (myNavigationController.viewControllers.isEmpty) {
            myNavigationController.viewControllers = [demoViewController]
            present(myNavigationController, animated: true) { self.demoViewControllerSetting(demoViewController, productName: productName, staffName: staffName) }
            return
        }
        
        myNavigationController._pushViewController(demoViewController) {
            self.demoViewControllerSetting(demoViewController, productName: productName, staffName: staffName)
        }
    }
    
    /// 取得同一頁的ViewController
    /// - Returns: DemoViewController
    func demoViewController() -> DemoViewController? {
        let demoViewController = self.storyboard?.instantiateViewController(withIdentifier: "DemoViewController") as? DemoViewController
        return demoViewController
    }
    
    /// 設定文字
    /// - Parameters:
    ///   - viewController: DemoViewController
    ///   - productName: String
    ///   - staffName: String
    func demoViewControllerSetting(_ viewController: DemoViewController, productName: String, staffName: String) {
        viewController.staffLabel.text = staffName
        viewController.productLabel.text = productName
    }
    
    /// 註冊收到推播時的反應
    func registerNotification() {
        
        NotificationCenter.default._register(name: Self.notificationName) { notification in
            guard let userInfo = notification.object as? [AnyHashable: Any] else { return }
            self.displayProductNameWithUserInfo(userInfo)
        }
    }
}
