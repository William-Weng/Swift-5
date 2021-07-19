//
//  ViewController.swift
//  CompositionalLayout_TableView
//
//  Created by William.Weng on 2020/9/8.
//  Copyright © 2020 William.Weng. All rights reserved.
//
/// [Using compositional collection view layouts in iOS 13](https://www.donnywals.com/using-compositional-collection-view-layouts-in-ios-13/)
/// [Modern Collection Views with Compositional Layouts](https://www.raywenderlich.com/5436806-modern-collection-views-with-compositional-layouts)
/// [UICollectionView Tutorial: Reusable Views, Selection and Reordering](https://www.raywenderlich.com/9477-uicollectionview-tutorial-reusable-views-selection-and-reordering)
/// [Stretchable Header view in UICollectionView— Swift 5, iOS](https://medium.com/@Anantha1992/stretchable-header-view-in-uicollectionview-swift-5-ios-a14a25dcd383)
/// [創建自定義UICollectionView layout - reloadData() / invalidateLayout()](https://www.jianshu.com/p/40868928a1cf)
/// [Compositional Layout 詳解　讓你簡單操作 CollectionView！](https://www.appcoda.com.tw/compositional-layout/)
/// [All you need to know about UICollectionViewCompositionalLayout](https://medium.com/flawless-app-stories/all-what-you-need-to-know-about-uicollectionviewcompositionallayout-f3b2f590bdbe)

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var myCollectionView: UICollectionView!
    
    private var sectionCount: Int = 3
    private var cellCountArray = Array(repeating: 15, count: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    @IBAction func tableViewLayout(_ sender: UIBarButtonItem) {
        let layout = Compositional.TableView.layout(height: 200, headerHeight: 44, footerHeight: 44, decorationType: MyCollectionReusableDecorationView.self)
        myCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    @IBAction func photoAlbumLayout(_ sender: UIBarButtonItem) {
        let layout = Compositional.PhotoAlbum.layout(height: 200, headerHeight: 44, footerHeight: 44, decorationType: MyCollectionReusableDecorationView.self, rowCount: 2)
        myCollectionView.setCollectionViewLayout(layout, animated: true)
        layout.invalidateLayout()
    }
    
    @IBAction func bookshelfLayout(_ sender: UIBarButtonItem) {
        let layout = Compositional.Bookshelf.layout(height: 200, headerHeight: 44, footerHeight: 44, decorationType: MyCollectionReusableDecorationView.self, rowCount: 3)
        myCollectionView.setCollectionViewLayout(layout, animated: true)
    }

    @IBAction func vendingMachineLayout(_ sender: UIBarButtonItem) {
        let layout = Compositional.VendingMachine.layout(height: 200, headerHeight: 44, footerHeight: 44, decorationType: MyCollectionReusableDecorationView.self, rowCount: 3)
        myCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    @IBAction func mixLayout(_ sender: UIBarButtonItem) {
        let layout = Compositional.Mix.layout(height: 200, headerHeight: 44, footerHeight: 44, decorationType: MyCollectionReusableDecorationView.self, rowCount: 3)
        myCollectionView.setCollectionViewLayout(layout, animated: true)
    }
}

// MARK: - @objc
extension ViewController {
    
    /// 縮合Cell
    @objc func tapHeaderHandle(_ recognizer: UITapGestureRecognizer) {
        
        guard let header = recognizer.view as? MyCollectionReusableHeader,
              let section = Optional.some(header.indexPath.section),
              let cellCount = cellCountArray[safe: section]
        else {
            return
        }
        
        cellCountArray[section] = (cellCount == 0) ? 21 : 0
        myCollectionView.reloadSections(IndexSet(integer: section))
    }
}

// MARK: - 基本設定
extension ViewController {
    
    /// 初始化設定
    private func initSetting() {
        
        let layout = Compositional.TableView.layout(height: 200, headerHeight: 44, footerHeight: 22)
        
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.setCollectionViewLayout(layout, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { return sectionCount }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let cellCount = cellCountArray[safe: section] else { return 0 }
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView._reusableCell(at: indexPath) as MyCollectionViewCell
        cell.configure(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let kind = Utility.ReusableSupplementaryViewKind(rawValue: kind) else { fatalError() }
        
        switch kind {
        case .none, .badge, .decoration: return UICollectionReusableView()
        case .header:
            
            let gesturer = UITapGestureRecognizer(target: self, action: #selector(tapHeaderHandle(_:)))
            let header = collectionView._reusableSupplementaryView(at: indexPath, ofKind: kind) as MyCollectionReusableHeader
            
            header.configure(with: indexPath)
            header.addGestureRecognizer(gesturer)
            
            return header
            
        case .footer:
            
            let footer = collectionView._reusableSupplementaryView(at: indexPath, ofKind: kind) as MyCollectionReusableFooter
            footer.configure(with: indexPath)
            
            return footer
        }
    }
}

// MARK: UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { wwPrint(indexPath) }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
}

