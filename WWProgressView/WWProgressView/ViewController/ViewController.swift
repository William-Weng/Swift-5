//
//  ViewController.swift
//  WWProgressView
//
//  Created by William.Weng on 2021/11/12.
//

import UIKit
import WWPrint

final class ViewController: UIViewController {
    
    @IBOutlet weak var myProgressView: ProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let icon = #imageLiteral(resourceName: "SoundOn")
        myProgressView.myDeleagte = self
        
        #if DEBUG
        myProgressView.configure(initValue: "1 / 5", font: .systemFont(ofSize: 36), icon: icon)
        #endif
        
        #if RELEASE
        myProgressView.configure(initValue: nil, font: .systemFont(ofSize: 10), icon: icon)
        #endif
        
        #if STAGE
        myProgressView.configure(initValue: "50 %", font: .systemFont(ofSize: 20), icon: icon)
        #endif
    }
}

// MARK: - ProgressViewDeleagte
extension ViewController: ProgressViewDeleagte {
    
    func valueChange(_ currentValue: CGFloat, maximumValue: CGFloat) -> ProgressViewDeleagte.ProgressViewInfomation {
        
        let percentage = Int(currentValue / maximumValue * 100)
        var icon = #imageLiteral(resourceName: "SoundOff")
        
        switch percentage {
        case 31...60: icon = #imageLiteral(resourceName: "SoundOn")
        case 61...: icon = #imageLiteral(resourceName: "SoundFull")
        default: icon = #imageLiteral(resourceName: "SoundOff")
        }
        
        return (text: "\(percentage) %", icon: icon)
    }
}
