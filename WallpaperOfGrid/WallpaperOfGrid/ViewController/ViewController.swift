//
//  ViewController.swift
//  WallpaperOfGrid
//
//  Created by William.Weng on 2019/8/19.
//  Copyright © 2019 William.Weng. All rights reserved.
//
/// [[限時免費] Grid Wallpaper 用色塊桌布管理桌面，找 App 更快速！（iPhone, iPad）](https://briian.com/61174/)

import UIKit

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool { return true }
    
    let reuseIdentifier = "GridCell"
    
    let colorInfos: [ColorInfo] = [
        (title: "紅色", color: .red),
        (title: "綠色", color: .green),
        (title: "藍色", color: .blue),
    ]
    
    var gridColor: UIColor = .red
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var saveWallpaperButton: UIButton!
    @IBOutlet weak var selectColorButton: UIButton!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    /// 存照片
    @IBAction func saveWallpaper(_ sender: UIButton) {
        guard let image = captureImageMaker(with: view) else { fatalError() }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    /// 改變顏色
    @IBAction func changeGridColor(_ sender: UIButton) {
        showGridColorSettingAlertController(with: sender)
    }
    
    /// 存完照片後的動作
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error { showAlertController(with: "錯誤", message: error.description); return }
        showAlertController(with: "成功", message: "已經存到您的照片內了")
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = gridColor
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iPhoneSizeInfomation.iconMaxCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = .white
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSizeMaker(with: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 0)
    }
}

// MARK: - 主工具
extension ViewController {
    
    /// 取得Screen上的距離數據 (用MarkMan量的)
    private func getScreenBoundsInfo(for iPhoneType: iPhoneSizeInfomation) -> iPhoneDesktopInfo? {
        return getScreenBoundsInfoArray()[iPhoneType]
    }
    
    /// 取得Screen上第一列 / 最後一列的icon位置
    private func getIconRangeInfo(for iPhoneType: iPhoneSizeInfomation) -> iPhoneIconRangeInfo? {
        return getIconRangeInfoArray()[iPhoneType]
    }
    
    /// 取得Screen上的距離數據Array (用MarkMan量的)
    private func getScreenBoundsInfoArray() -> [iPhoneSizeInfomation: iPhoneDesktopInfo] {
        
        let screenBoundsInfos: [iPhoneSizeInfomation: iPhoneDesktopInfo] = [
            ._35inch: iPhoneDesktopInfo(iconSize: CGSize(width: 60, height: 60), gapSize: CGSize(width: 16, height: 28), barDistance: (top: 27, bottom: 129)),
            ._40inch: iPhoneDesktopInfo(iconSize: CGSize(width: 60, height: 60), gapSize: CGSize(width: 16, height: 28), barDistance: (top: 27, bottom: 129)),
            ._47inch: iPhoneDesktopInfo(iconSize: CGSize(width: 60, height: 60), gapSize: CGSize(width: 27, height: 28), barDistance: (top: 30, bottom: 137)),
            ._55inch: iPhoneDesktopInfo(iconSize: CGSize(width: 60, height: 60), gapSize: CGSize(width: 34.75, height: 40), barDistance: (top: 38, bottom: 139)),
            ._58inch: iPhoneDesktopInfo(iconSize: CGSize(width: 60, height: 60), gapSize: CGSize(width: 27, height: 42), barDistance: (top: 72, bottom: 170)),
            ._61inch: iPhoneDesktopInfo(iconSize: CGSize(width: 60, height: 60), gapSize: CGSize(width: 27, height: 42), barDistance: (top: 72, bottom: 170)),
            ._65inch: iPhoneDesktopInfo(iconSize: CGSize(width: 64, height: 64), gapSize: CGSize(width: 31.6, height: 49), barDistance: (top: 78, bottom: 192)),
        ]
        
        return screenBoundsInfos
    }
    
    /// 取得Screen上第一列 / 最後一列的icon位置Array
    private func getIconRangeInfoArray() -> [iPhoneSizeInfomation: iPhoneIconRangeInfo] {
        
        let screenBoundsInfos: [iPhoneSizeInfomation: iPhoneIconRangeInfo] = [
            ._35inch: iPhoneIconRangeInfo(firstColumn: 0...3, lastColumn: 20...23),
            ._40inch: iPhoneIconRangeInfo(firstColumn: 0...3, lastColumn: 20...23),
            ._47inch: iPhoneIconRangeInfo(firstColumn: 0...3, lastColumn: 24...27),
            ._55inch: iPhoneIconRangeInfo(firstColumn: 0...3, lastColumn: 24...27),
            ._58inch: iPhoneIconRangeInfo(firstColumn: 0...3, lastColumn: 24...27),
            ._61inch: iPhoneIconRangeInfo(firstColumn: 0...3, lastColumn: 24...27),
            ._65inch: iPhoneIconRangeInfo(firstColumn: 0...3, lastColumn: 24...27),
        ]
        
        return screenBoundsInfos
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 初始化設定
    private func initSetting() {
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.contentInsetAdjustmentBehavior = .never
    }
    
    /// 擷取UIView的畫面 => UIImage
    private func captureImageMaker(with view: UIView) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        buttonsHidden(true)

        defer {
            UIGraphicsEndImageContext()
            buttonsHidden(false)
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        return image
    }
    
    /// 產生item對應的大小
    private func itemSizeMaker(with indexPath: IndexPath) -> CGSize {
        
        guard let iPhoneType = iPhoneSizeInfomation.type,
              let desktopSizeInfo = getScreenBoundsInfo(for: iPhoneType),
              let iconRangeInfo = getIconRangeInfo(for: iPhoneType),
              let iconSize = Optional.some(desktopSizeInfo.iconSize),
              let gapSize = Optional.some(desktopSizeInfo.gapSize),
              let barDistance = Optional.some(desktopSizeInfo.barDistance),
              let marginTop: CGFloat = Optional.some(barDistance.top - gapSize.height * 0.5),
              let bottomHeight: CGFloat = Optional.some(barDistance.bottom - gapSize.height * 0.5),
              let rowType = RowType(rawValue: indexPath.row % 4)
        else {
            return .zero
        }
        
        var itemSize = CGSize(width: iconSize.width + gapSize.width, height: iconSize.height + gapSize.height)
        
        switch indexPath.row {
        case iconRangeInfo.firstColumn: itemSize.height += marginTop
        case iconRangeInfo.lastColumn: itemSize.height = bottomHeight
        default: break
        }
        
        if rowType == .first || rowType == .last {
            itemSize.width += gapSize.width * 0.5
        }
        
        return itemSize
    }
    
    /// 設定顏色的提示視窗
    private func showGridColorSettingAlertController(with button: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for colorInfo in colorInfos {
            
            let alertAction = UIAlertAction(title: colorInfo.title, style: .default) { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.gridColor = colorInfo.color
                button.backgroundColor = strongSelf.gridColor
            }
            
            alertController.addAction(alertAction)
        }
        
        present(alertController, animated: true)
    }
    
    /// 提示視窗
    private func showAlertController(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    /// 按鍵顯示 / 隱藏
    private func buttonsHidden(_ isHidden: Bool) {
        saveWallpaperButton.isHidden = isHidden
        selectColorButton.isHidden = isHidden
    }
}

