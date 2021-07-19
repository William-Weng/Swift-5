//
//  ViewController.swift
//  Graphiclock
//
//  Created by William on 2019/7/24.
//  Copyright © 2019 William. All rights reserved.
//
/// [Swift — 玩玩 手勢／圖形解鎖（Gesture Password） - Jeremy Xue ‘s Blog - Medium](https://medium.com/jeremy-xue-s-blog/swift-玩玩-手勢-圖形解鎖-gesture-password-6863654b3f8b)

import UIKit
import AudioToolbox

/// 解鎖的類型
enum LockType: Int {
    case setting = 0
    case unlock = 1
}

// MARK: - Main
class ViewController: UIViewController {

    @IBOutlet var lockCollectionView: LockCollectionView!
    @IBOutlet var lockSegmentedControl: UISegmentedControl!

    private let cellIdentifier = "LockCell"             /* Cell的名字 */

    private var lockRowCount = 3                        /* Cell的數量 */
    private var lockType: LockType = .setting           /* 當前的解鎖狀態 */

    private var lineLayers = [CAShapeLayer]()           /* 畫在View上的Layer */
    private var moveLayer: CAShapeLayer?                /* 跟著手指移動的Layer */
    
    private var finalPassword = [Int]()                 /* 記錄最後設定密碼 */
    private var selectedPassword = [Int]()              /* 當前畫出的密碼 */
    private var currentPoint: CGPoint?                  /* 目前滑到的最後一個點 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    /// 改變Row的數量
    @IBAction func changeLockRows(_ sender: UIStepper) {
        
        if (finalPassword.count != 0) { showMessageAlert("密碼請重新設定") }
        
        lockRowCount = Int(sender.value)
        clearAllData()
        finalPassword = []
    }
    
    /// 改變Lock的類型
    @IBAction func changeLockType(_ sender: UISegmentedControl) {
        
        guard let type = LockType(rawValue: sender.selectedSegmentIndex) else { return }
        
        lockType = type
        
        switch type {
        case .setting: lockCollectionView.backgroundColor = .blue
        case .unlock: lockCollectionView.backgroundColor = .purple
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lockCellCount(with: lockRowCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return lockCell(with: collectionView, for: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return lockCellSize(with: collectionView.bounds.width, for: lockRowCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lockCellWidth(with: collectionView.bounds.width, for: lockRowCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return lockCellWidth(with: collectionView.bounds.width, for: lockRowCount)
    }
}

// MARK: - LockCollectionViewDelegate
extension ViewController: LockCollectionViewDelegate {
    
    func move(to point: CGPoint) {
        drawLockLayerForMove(to: point)
    }
    
    func selectedItem(at indexPath: IndexPath) {
        appendPassword(at: indexPath)
    }
    
    func moveEnded() {
        
        switch lockType {
        case .setting: finalPasswordSetting()
        case .unlock: checkPassword()
        }
        
        clearAllData()
        playSystemSound(soundID: kSystemSoundID_Vibrate)
    }
}

// MARK: - 主工具
extension ViewController {
    
    /// 初始化設定
    private func initSetting() {
        lockCollectionView.delegate = self
        lockCollectionView.dataSource = self
        lockCollectionView.lockCollectionViewDelegate = self
    }
    
    /// 圖形鎖的外觀 (圓形的)
    private func lockCell(with collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        
        let lockCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        lockCell.tag = indexPath.row
        lockCell.layer.cornerRadius = lockCell.bounds.height / 2
        lockCell.layer.borderWidth = 3
        lockCell.layer.borderColor = lockCellBorderColor(for: indexPath)
        
        return lockCell
    }
    
    /// 畫圖形鎖的線 (完成時)
    private func drawLockLayerForSelected(to point: CGPoint) {
        
        if let _currentPoint = currentPoint {
            
            let layerPath = lockShapeLayerPath(from: _currentPoint, to: point)
            let lockShapeLayer = lockShapeLayerMaker(for: layerPath, color: .red)
            
            lineLayers.append(lockShapeLayer)
            view.layer.addSublayer(lockShapeLayer)
        }

        currentPoint = point
    }
    
    /// 畫圖形鎖的線 (移動時)
    private func drawLockLayerForMove(to point: CGPoint) {
        
        if let _currentPoint = currentPoint {
            
            let layerPath = lockShapeLayerPath(from: _currentPoint, to: point)
            
            if (moveLayer == nil) {
                moveLayer = lockShapeLayerMaker(for: layerPath, color: .green)
                view.layer.addSublayer(moveLayer!)
                return
            }
            
            moveLayerSetting(for: layerPath, color: .green)
        }
    }
    
    /// 產生畫線的Layer
    private func lockShapeLayerMaker(for path: UIBezierPath, color: UIColor) -> CAShapeLayer {
        return lockLayerSetting(for: path, color: color)
    }
    
    /// 設定moveLayer
    private func moveLayerSetting(for path: UIBezierPath, color: UIColor) {
        _ = lockLayerSetting(moveLayer, for: path, color: color)
    }
    
    /// 記錄Password的值 (畫線)
    private func appendPassword(at indexPath: IndexPath) {
        
        guard !selectedPassword.contains(indexPath.row),
              let lockCell = lockCollectionView.cellForItem(at: indexPath)
        else {
            return
        }
        
        selectedPassword.append(indexPath.row)
        drawLockLayerForSelected(to: lockCell.center)
        
        moveLayer?.removeFromSuperlayer()
        moveLayer = nil
        
        playSystemSound(soundID: 1520)
        lockCollectionView.reloadItems(at: [indexPath])
    }
    
    /// 記錄密碼
    private func finalPasswordSetting() {
        
        if selectedPassword.count > 0 {
            let message = "您所選的密碼是：\(selectedPassword)"
            finalPassword = selectedPassword
            showMessageAlert(message)
        }
    }
    
    /// 比對密碼
    private func checkPassword() {
        
        if finalPassword.count > 0 {
            let message = (finalPassword != selectedPassword) ? "答錯了" : "答對了"
            showMessageAlert(message)
        }
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 圖形鎖的數量 (3 x 3)
    private func lockCellCount(with row: Int) -> Int {
        return row * row
    }
    
    /// 圖形鎖的平均寬度
    private func lockCellWidth(with width: CGFloat, for row: Int) -> CGFloat {
        
        let cellWidth = width / CGFloat(row * 2 - 1)
        let cellWidthString = String(format: "%.2f", cellWidth)
        return CGFloat(Float(cellWidthString)!)
    }
    
    /// 圖形鎖的平均大小
    private func lockCellSize(with width: CGFloat, for row: Int) -> CGSize {
        let cellWidth = lockCellWidth(with: width, for: row)
        return CGSize(width: cellWidth, height: cellWidth)
    }

    /// 圖形鎖的外框顏色 (選到的 / 沒選到)
    private func lockCellBorderColor(for indexPath: IndexPath) -> CGColor {
        let cellBorderColor = selectedPassword.contains(indexPath.row) ? UIColor.green.cgColor : UIColor.white.cgColor
        return cellBorderColor
    }
    
    /// 畫線的路徑
    private func lockShapeLayerPath(from point1: CGPoint, to point2: CGPoint) -> UIBezierPath {
        
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: point1)
        bezierPath.addLine(to: point2)
        
        return bezierPath
    }
    
    /// 清除所有資料 (Layer / Password)
    private func clearAllData() {
        
        lineLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        
        moveLayer?.removeFromSuperlayer()
        
        lineLayers.removeAll()
        selectedPassword.removeAll()
        
        moveLayer = nil
        currentPoint = nil
        
        lockCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    /// 設定畫線的Layer (有舊的就用舊的，不然就產生新的)
    private func lockLayerSetting(_ layer: CAShapeLayer? = nil, for path: UIBezierPath, color: UIColor) -> CAShapeLayer {
        
        let _layer = (layer != nil) ? layer! : CAShapeLayer()
        
        _layer.frame = lockCollectionView.bounds
        _layer.position = lockCollectionView.center
        _layer.fillColor = nil
        _layer.lineWidth = 3
        _layer.strokeColor = color.cgColor
        _layer.lineCap = .round
        _layer.path = path.cgPath
        
        return _layer
    }
    
    /// 播放系統音效 (震動)
    private func playSystemSound(soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    /// 提示視窗
    private func showMessageAlert(_ message: String) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
