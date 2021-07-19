//
//  ViewController.swift
//  AppDynamicIcons
//
//  Created by William.Weng on 2020/11/9.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private var iconIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 放ICON圖 => 去info.plist設定 => 換ICON
    @IBAction func changeAppIcon(_ sender: UIButton) {
        
        guard let dynamicIconKeys = Utility.shared.appDynamicIcons() else { return }

        let _iconIndex = iconIndex % dynamicIconKeys.count
        iconIndex += 1
        
        Utility.shared.dynamicAppIcon(for: dynamicIconKeys[_iconIndex]) { (result) in
            
            switch result {
            case .failure(let error): print(error)
            case .success(let iconName): print(iconName!)
            }
        }
    }
}
