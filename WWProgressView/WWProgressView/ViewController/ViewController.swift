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
    @IBOutlet weak var myProgressView2: ProgressView!
    @IBOutlet weak var myProgressView3: ProgressView!

    private let count: UInt = 10
    private let icon: (continuous: UIImage, segmented: UIImage, segmented2: UIImage) = (#imageLiteral(resourceName: "SoundOn"), #imageLiteral(resourceName: "WifiOn"), #imageLiteral(resourceName: "BulbOff"))
    
    private enum Identifier: String {
        case continuous = "continuous"
        case segmented = "segmented"
        case segmented2 = "segmented2"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myProgressView.myDeleagte = self
        myProgressView2.myDeleagte = self
        myProgressView3.myDeleagte = self
        
        myProgressView.configure(id: "\(Identifier.continuous)", initValue: "50%", font: .systemFont(ofSize: 16), icon: icon.continuous, type: .continuous)
        myProgressView2.configure(id: "\(Identifier.segmented)", initValue: "5/\(count)", font: .systemFont(ofSize: 20), icon: icon.segmented, type: .segmented(count))
        myProgressView3.configure(id: "\(Identifier.segmented2)", initValue: "0", font: .systemFont(ofSize: 24), icon: icon.segmented2, type: .segmented(count))
        
        #if DEBUG
        wwPrint("DEBUG")
        #endif
        
        #if RELEASE
        wwPrint("RELEASE")
        #endif
        
        #if STAGE
        wwPrint("STAGE")
        #endif
    }
}

// MARK: - ProgressViewDeleagte
extension ViewController: ProgressViewDeleagte {
    
    func valueChange(identifier: String, currentValue: CGFloat, maximumValue: CGFloat, isVertical: Bool) -> ProgressViewDeleagte.ProgressViewInfomation {
        
        guard let identifier = Identifier(rawValue: identifier) else { fatalError() }
        
        switch identifier {
        case .continuous: return continuousTypeInfo(currentValue: currentValue, maximumValue: maximumValue)
        case .segmented: return segmentedTypeInfo(currentValue: currentValue, maximumValue: maximumValue)
        case .segmented2: return segmentedTypeInfo2(currentValue: currentValue, maximumValue: maximumValue)
        }
    }
}

// MARK: - 測試用
extension ViewController {
    
    /// 連續的顯示效果
    private func continuousTypeInfo(currentValue: CGFloat, maximumValue: CGFloat) -> ProgressViewDeleagte.ProgressViewInfomation {
        
        let percentage = Int(currentValue / maximumValue * 100)
        var icon = #imageLiteral(resourceName: "SoundOff")
        
        switch percentage {
        case 31...60: icon = #imageLiteral(resourceName: "SoundOn")
        case 61...: icon = #imageLiteral(resourceName: "SoundFull")
        default: icon = #imageLiteral(resourceName: "SoundOff")
        }
        
        return (text: "\(percentage) %", icon: icon)
    }
    
    /// 分段的顯示效果
    private func segmentedTypeInfo(currentValue: CGFloat, maximumValue: CGFloat) -> ProgressViewDeleagte.ProgressViewInfomation {
        
        let index = Int(currentValue * CGFloat(count) / maximumValue)
        var icon = #imageLiteral(resourceName: "WifiOff")
        
        switch index {
        case 3...6: icon = #imageLiteral(resourceName: "WifiOn")
        case 7...: icon = #imageLiteral(resourceName: "WifiFull")
        default: icon = #imageLiteral(resourceName: "WifiOff")
        }
        
        return (text: "\(index)/\(count)", icon: icon)
    }
    
    /// 分段的顯示效果2
    private func segmentedTypeInfo2(currentValue: CGFloat, maximumValue: CGFloat) -> ProgressViewDeleagte.ProgressViewInfomation {
        
        let level = Int(currentValue * CGFloat(count) / maximumValue) - Int(count) / 2
        var icon = #imageLiteral(resourceName: "WifiOff")
        
        switch level {
        case (-5)...(-2): icon = #imageLiteral(resourceName: "BulbOff")
        case (-1)...2: icon = #imageLiteral(resourceName: "BulbOn")
        default: icon = #imageLiteral(resourceName: "BulbFull")
        }
        
        return (text: "\(level)", icon: icon)
    }
}
