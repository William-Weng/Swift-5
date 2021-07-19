//
//  ViewController.swift
//  WhatsAppToolBar
//
//  Created by William.Weng on 2021/6/2.
//
/// [UI Transition 教學：一起來學習 Whatsapp 也在用的 UI 轉場技巧吧！](https://www.appcoda.com.tw/ui-transition/)

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myToolbar: UIToolbar!
    
    private let itemsPerRow = 2
    
    private var sectionInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 1.0, right: 10.0)
    private var tabbarOriginalFrame: CGRect?
    private var isTabbarHidden: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    @IBAction func changeToolBar(_ sender: UIBarButtonItem) {
        
        if isTabbarHidden == nil {
            isTabbarHidden = true
        } else {
            isTabbarHidden?.toggle()
        }
        
        changeToolbarHeight()
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return MyCollectionViewCell.Colors.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView._reusableCell(at: indexPath) as MyCollectionViewCell
        cell.configure(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = itemWidthMaker(sectionInsets: sectionInsets, count: itemsPerRow)
        return CGSize(width: Int(itemWidth), height: Int(itemWidth))
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 初始設定
    private func initSetting() {
        
        self.myCollectionView.delegate = self
        self.myCollectionView.dataSource = self
        self.updateToolbarHeight()
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: didRotate)
    }
    
    /// 計算出Item的平均寬度
    /// - Parameters:
    ///   - sectionInsets: Item的間隔
    ///   - count: Item單行的數量
    /// - Returns: CGFloat
    private func itemWidthMaker(sectionInsets: UIEdgeInsets, count: Int) -> CGFloat {

        let paddingSpace: CGFloat = sectionInsets.left * CGFloat((count + 1))
        let availableWidth = view.bounds.width - paddingSpace
        let itemWidth = availableWidth / CGFloat(count)
        
        return itemWidth
    }
    
    /// 更新Tabbar高度 (手機旋轉時)
    private func updateToolbarHeight() {
        tabbarOriginalFrame = self.tabBarController?.tabBar.frame
        changeToolbarHeight()
    }
    
    /// 更新Tabbar高度 (變換座標 => 移出畫面外)
    /// - 如果使用tabBarController?.tabBar.isHidden，轉旋時會造成Toolbar高度 => 44.0
    private func changeToolbarHeight() {
        
        guard let tabbarOriginalFrame = tabbarOriginalFrame else { return }
        
        toolbarHeightConstraint.constant = tabbarOriginalFrame.height
        
        if let isTabbarHidden = self.isTabbarHidden {
            
            UIView.animate(withDuration: 0.2) {
                self.tabBarController?.tabBar.frame.origin.y = (!isTabbarHidden) ? tabbarOriginalFrame.origin.y : tabbarOriginalFrame.origin.y + tabbarOriginalFrame.height
            }
        }
    }
    
    /// 更新Tabbar高度 (手機旋轉時)
    private func didRotate(notification: Notification) { updateToolbarHeight() }
}

// MARK: - MyCollectionViewCell
final class MyCollectionViewCell: UICollectionViewCell, CellReusable {
    
    static let Colors: [UIColor] = [.red, .blue, .cyan, .darkGray, .green, .magenta, .orange, .purple, .systemYellow]
    
    func configure(with indexPath: IndexPath) {
        self.contentView.backgroundColor = Self.Colors[safe: indexPath.row]
    }
}
