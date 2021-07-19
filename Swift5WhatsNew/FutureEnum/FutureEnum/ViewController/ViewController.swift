//
//  ViewController.swift
//  FutureEnum
//
//  Created by William on 2019/4/3.
//  Copyright © 2019 William. All rights reserved.
//
/// [Swift 5.0 新特性](https://www.jianshu.com/p/afa74763b78b)

import UIKit

class ViewController: UIViewController {

    enum PasswordError: Error {
        case short
        case obvious
        case simple
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController {
    
    /// 舊的enum寫法
    func showOld(error: PasswordError) {
        
        switch error {
        case .short:
            print("Your password was too short.")
        case .obvious:
            print("Your password was too obvious.")
        default:
            print("Your password was too simple.")
        }
    }
    
    /// 新的enum寫法 (@unknown default: => 如果有未完全使用的話，會有提示產生)
    func showNew(error: PasswordError) {
        
        switch error {
        case .short:
            print("Your password was too short.")
        case .obvious:
            print("Your password was too obvious.")
        @unknown default:
            print("Your password wasn't suitable.")
        }
    }
}
