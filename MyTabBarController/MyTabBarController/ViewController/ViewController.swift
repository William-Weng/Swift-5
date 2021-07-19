//
//  ViewController.swift
//  MyTabBarController
//
//  Created by William.Weng on 2021/6/7.
//

import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default._post(name: ._firstViewControllerDidLoad, object: tabBarController?.tabBar.items?.count)
    }
}
