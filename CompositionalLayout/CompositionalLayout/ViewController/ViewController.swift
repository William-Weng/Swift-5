//
//  ViewController.swift
//  CompositionalLayout
//
//  Created by William.Weng on 2021/11/2.
//

import UIKit
import WWPrint

final class ViewController: UIViewController {

    @IBOutlet weak var myCollectionView: UICollectionView!
    
    private let badgeViewKey = "First"
    private let contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
    private let edgeInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
    private let backgroundInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
    private let firstBadgeSetting: CompositionalLayout.WW.BadgeSetting = (key: "First", size: (width: .absolute(20), height: .absolute(20)), zIndex: 100,
containerAnchor: (edges: [.top, .leading], absoluteOffset: CGPoint(x: 10, y: 10)), itemAnchor: (edges: [.bottom, .trailing], absoluteOffset: CGPoint(x: 0, y: 0)))
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func changeLayout(_ sender: UIBarButtonItem) {
        myCollectionView.setCollectionViewLayout(bookshelfLayout()!, animated: false)
        myCollectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { return 10 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return MyCollectionViewCell.dataSource.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView._reusableCell(at: indexPath) as MyCollectionViewCell
        cell.configure(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
                
        if kind == "\(CompositionalLayout.WW.ReusableSupplementaryViewKind.header)" {
            let header = collectionView._reusableSupplementaryView(at: indexPath, ofKind: .header) as MyCollectionReusableHeader
            header.configure(with: indexPath)
            return header
        }
        
        if kind == "\(CompositionalLayout.WW.ReusableSupplementaryViewKind.footer)" {
            let header = collectionView._reusableSupplementaryView(at: indexPath, ofKind: .footer) as MyCollectionReusableHeader
            header.configure(with: indexPath)
            return header
        }

        let badge = collectionView._reusableSupplementaryView(at: indexPath, ofKind: .badge(key: badgeViewKey)) as MyCollectionReusableBadge
        badge.configure(with: indexPath)
        
        return badge
    }
}

// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate {}

// MARK: 小工具
extension ViewController {
    
    /// 初始化設定
    private func initSetting() {
        
        guard let layout = vendingMachineLayout(),
              let newLayout = layoutRegister(layout)
        else {
            return
        }
        
        myCollectionView._delegateAndDataSource(with: self)
        myCollectionView.setCollectionViewLayout(newLayout, animated: true)
    }
}

// MARK: - CompositionalLayout
extension ViewController {
    
    /// 註冊CollectionReusableView
    /// - Parameter layout:
    /// - Returns: UICollectionViewLayout?
    private func layoutRegister(_ layout: UICollectionViewCompositionalLayout?) -> UICollectionViewCompositionalLayout? {
        
        let newLayout = layout?
            ._register(with: myCollectionView, supplementaryViewClass: MyCollectionReusableHeader.self, ofKind: .header)
            ._register(with: myCollectionView, supplementaryViewClass: MyCollectionReusableHeader.self, ofKind: .footer)
            ._register(with: myCollectionView, supplementaryViewClass: MyCollectionReusableBadge.self, ofKind: .badge(key: badgeViewKey))
            ._register(with: MyCollectionReusableDecoration.self, ofKind: .decoration)
            ._register(with: MyCollectionReusableBadge.self, ofKind: .badge(key: badgeViewKey))
        
        return newLayout
    }
    
    /// 長得像UITableView的Layout
    /// - Returns: UICollectionViewLayout?
    private func tableViewLayout() -> UICollectionViewCompositionalLayout? {
        
        let layout = CompositionalLayout.ww
            .addItem(width: .fractionalWidth(1.0), height: .absolute(120), contentInsets: edgeInsets, badgeSetting: nil)
            .setDecoration(contentInsets: backgroundInsets)
            .setGroup(width: .fractionalWidth(1.0), height: .absolute(120), scrollingDirection: .horizontal)
            .setSection(scrollingBehavior: .none, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }
    
    /// 長得像相簿的Layout
    /// - Returns: UICollectionViewLayout?
    private func photoAlbumLayout() -> UICollectionViewCompositionalLayout? {
        
        let layout = CompositionalLayout.ww
            .addItem(width: .fractionalWidth(1/3), height: .absolute(120), contentInsets: edgeInsets)
            .addItem(width: .fractionalWidth(1/3), height: .absolute(120), contentInsets: edgeInsets)
            .addItem(width: .fractionalWidth(1/3), height: .absolute(120), contentInsets: edgeInsets)
            .setDecoration(contentInsets: backgroundInsets)
            .setGroup(width: .fractionalWidth(1.0), height: .absolute(120), scrollingDirection: .horizontal)
            .setSection(scrollingBehavior: .none, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }
    
    /// 長得像書櫃的Layout
    /// - Returns: UICollectionViewLayout?
    private func bookshelfLayout() -> UICollectionViewCompositionalLayout? {
        
        let layout = CompositionalLayout.ww
            .addItem(width: .fractionalWidth(1.0), height: .absolute(120), contentInsets: edgeInsets, badgeSetting: nil)
            .setDecoration(contentInsets: backgroundInsets)
            .setGroup(width: .fractionalWidth(1/4), height: .absolute(120), scrollingDirection: .vertical)
            .setSection(scrollingBehavior: .continuous, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }
    
    /// 長得像自動販賣機的Layout
    /// - Returns: UICollectionViewLayout?
    private func vendingMachineLayout() -> UICollectionViewCompositionalLayout? {
        
        let layout = CompositionalLayout.ww
            .addItem(width: .fractionalWidth(1.0), height: .absolute(40), contentInsets: edgeInsets, badgeSetting: nil)
            .addItem(width: .fractionalWidth(1.0), height: .absolute(40), contentInsets: edgeInsets, badgeSetting: nil)
            .addItem(width: .fractionalWidth(1.0), height: .absolute(40), contentInsets: edgeInsets, badgeSetting: nil)
            .setDecoration(contentInsets: backgroundInsets)
            .setGroup(width: .fractionalWidth(1/2), height: .absolute(120), scrollingDirection: .vertical)
            .setSection(scrollingBehavior: .continuousGroupLeadingBoundary, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }
}
