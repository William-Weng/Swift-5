//
//  CompositionalLayout+.swift
//  CompositionalLayout_TableView
//
//  Created by William.Weng on 2020/9/8.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

// MARK: - CompositionalLayout
final class Compositional: NSObject {}

// MARK: - typealias
extension Compositional {
    typealias DecorationItemInfomation<T: UICollectionReusableView> = (items: [NSCollectionLayoutDecorationItem], kind: Utility.ReusableSupplementaryViewKind, type: T.Type)    // 修飾用的背景View資訊
}

// MARK: - TableView Layout
extension Compositional {
    
    /// 單列上下垂直捲動 => 跟TableView一樣
    final class TableView: NSObject {
        
        /// 輸出Layout (header / footer / decorationItem 選填，rowCount永遠是1)
        static func layout<T: UICollectionReusableView>(height: CGFloat, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil, decorationType: T.Type? = nil) -> UICollectionViewCompositionalLayout {
            
            let items = [layoutItem(height: height)]
            let group = layoutGroup(height: height, items: items)
            let section = layoutSection(group: group)
            
            if let headerHeight = headerHeight { section.boundarySupplementaryItems.append(layoutHeader(height: headerHeight)) }
            if let footerHeight = footerHeight { section.boundarySupplementaryItems.append(layoutFooter(height: footerHeight)) }
            
            guard let decorationType = decorationType else { return Compositional.layoutRegister(section: section, decorationInfo: nil) }
            
            let decorationKind: Utility.ReusableSupplementaryViewKind = .decoration
            let decorationInfo: DecorationItemInfomation = (items: [layoutDecorationItem(kind: decorationKind)], kind: decorationKind, type: decorationType)
            let layout = Compositional.layoutRegister(section: section, decorationInfo: decorationInfo)
            
            return layout
        }
        
        /// section的設定 (滾動方向不動)
        fileprivate static func layoutSection(group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
            return Compositional.layoutSection(group: group, orthogonalScrollingBehavior: .none)
        }
        
        /// group的大小 (跟畫面一樣大)
        fileprivate static func layoutGroup(height: CGFloat, items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
            return Compositional.layoutGroup(height: height, fractionalWidth: 1.0, items: items)
        }
        
        /// item的大小 (跟Group一樣大 => 1：1，高度由Group決定)
        fileprivate static func layoutItem(height: CGFloat) -> NSCollectionLayoutItem {
            return Compositional.layoutItem(height: height, fractionalWidth: 1.0)
        }
        
        /// header的大小
        fileprivate static func layoutHeader(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .header) -> NSCollectionLayoutBoundarySupplementaryItem {
            return Compositional.layoutHeader(height: height, ofKind: kind)
        }
        
        /// footer的大小
        fileprivate static func layoutFooter(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .footer) -> NSCollectionLayoutBoundarySupplementaryItem {
            return Compositional.layoutFooter(height: height, ofKind: kind)
        }
    }
}

// MARK: - PhotoAlbum Layout
extension Compositional {
    
    /// 多列上下垂直捲動 => 跟相簿一樣
    final class PhotoAlbum: NSObject {
        
        /// 輸出Layout (header / footer / decorationItem 選填)
        static func layout<T: UICollectionReusableView>(height: CGFloat, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil, decorationType: T.Type? = nil, rowCount: UInt = 3) -> UICollectionViewCompositionalLayout {
            
            let items = [layoutItem(height: height, rowCount: rowCount)]
            let group = layoutGroup(height: height, items: items)
            let section = layoutSection(group: group)

            if let headerHeight = headerHeight { section.boundarySupplementaryItems.append(layoutHeader(height: headerHeight)) }
            if let footerHeight = footerHeight { section.boundarySupplementaryItems.append(layoutFooter(height: footerHeight)) }

            guard let decorationType = decorationType else { return Compositional.layoutRegister(section: section, decorationInfo: nil) }
            
            let decorationKind: Utility.ReusableSupplementaryViewKind = .decoration
            let decorationInfo: DecorationItemInfomation = (items: [layoutDecorationItem(kind: decorationKind)], kind: decorationKind, type: decorationType)
            let layout = Compositional.layoutRegister(section: section, decorationInfo: decorationInfo)

            return layout
        }
        
        /// section的設定 (滾動方向不動)
        fileprivate static func layoutSection(group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
            return Compositional.layoutSection(group: group, orthogonalScrollingBehavior: .none)
        }
        
        /// group的大小 (跟畫面一樣大)
        fileprivate static func layoutGroup(height: CGFloat, items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
            return Compositional.layoutGroup(height: height, fractionalWidth: 1.0, items: items)
        }
        
        /// item的大小 (一列需要幾個)
        fileprivate static func layoutItem(height: CGFloat, rowCount: UInt) -> NSCollectionLayoutItem {
            return Compositional.layoutItem(height: height, fractionalWidth: 1.0 / CGFloat(rowCount))
        }
        
        /// header的大小
        fileprivate static func layoutHeader(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .header) -> NSCollectionLayoutBoundarySupplementaryItem {
            return Compositional.layoutHeader(height: height, ofKind: kind)
        }
        
        /// footer的大小
        fileprivate static func layoutFooter(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .footer) -> NSCollectionLayoutBoundarySupplementaryItem {
            return Compositional.layoutFooter(height: height, ofKind: kind)
        }
    }
}

// MARK: - Bookshelf Layout
extension Compositional {
    
    /// 單列左右水平捲動 => 跟書架一樣
    final class Bookshelf: NSObject {
        
        /// 輸出Layout (header / footer / decorationItem 選填)
        static func layout<T: UICollectionReusableView>(height: CGFloat, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil, decorationType: T.Type? = nil, rowCount: UInt = 3) -> UICollectionViewCompositionalLayout {
            
            let items = [layoutItem(height: height)]
            let group = layoutGroup(height: height, items: items, rowCount: rowCount)
            let section = layoutSection(group: group)
            
            if let headerHeight = headerHeight { section.boundarySupplementaryItems.append(layoutHeader(height: headerHeight)) }
            if let footerHeight = footerHeight { section.boundarySupplementaryItems.append(layoutFooter(height: footerHeight)) }
            
            guard let decorationType = decorationType else { return Compositional.layoutRegister(section: section, decorationInfo: nil) }
            
            let decorationKind: Utility.ReusableSupplementaryViewKind = .decoration
            let decorationInfo: DecorationItemInfomation = (items: [layoutDecorationItem(kind: decorationKind)], kind: decorationKind, type: decorationType)
            let layout = Compositional.layoutRegister(section: section, decorationInfo: decorationInfo)

            return layout
        }
        
        /// section的設定 (一格一格滾動 => 自動置中)
        fileprivate static func layoutSection(group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
            return Compositional.layoutSection(group: group, orthogonalScrollingBehavior: .groupPagingCentered)
        }
        
        /// group的大小 (一列需要幾個)
        fileprivate static func layoutGroup(height: CGFloat, items: [NSCollectionLayoutItem], rowCount: UInt) -> NSCollectionLayoutGroup {
            return Compositional.layoutGroup(height: height, fractionalWidth: 1.0 / CGFloat(rowCount), items: items)
        }
        
        /// item的大小 (跟畫面一樣大)
        fileprivate static func layoutItem(height: CGFloat) -> NSCollectionLayoutItem {
            return Compositional.layoutItem(height: height, fractionalWidth: 1.0)
        }
        
        /// header的大小
        fileprivate static func layoutHeader(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .header) -> NSCollectionLayoutBoundarySupplementaryItem {
            return Compositional.layoutHeader(height: height, ofKind: kind)
        }
        
        /// footer的大小
        fileprivate static func layoutFooter(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .footer) -> NSCollectionLayoutBoundarySupplementaryItem {
            return Compositional.layoutFooter(height: height, ofKind: kind)
        }
    }
}

// MARK: - VendingMachine Layout
extension Compositional {
    
    /// 多列左右水平捲動 => 跟販賣機一樣
    final class VendingMachine: NSObject {
        
        /// 輸出Layout (header / footer / decorationItem 選填)
        static func layout<T: UICollectionReusableView>(height: CGFloat, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil, decorationType: T.Type? = nil, rowCount: UInt = 3) -> UICollectionViewCompositionalLayout {
            
            let items = Array(repeating: layoutItem(height: height / CGFloat(rowCount)), count: Int(rowCount))
            let group = layoutGroup(height: height, items: items, rowCount: rowCount)
            let section = layoutSection(group: group)
            
            if let headerHeight = headerHeight { section.boundarySupplementaryItems.append(layoutHeader(height: headerHeight)) }
            if let footerHeight = footerHeight { section.boundarySupplementaryItems.append(layoutFooter(height: footerHeight)) }
            
            guard let decorationType = decorationType else { return Compositional.layoutRegister(section: section, decorationInfo: nil) }
                        
            let decorationKind: Utility.ReusableSupplementaryViewKind = .decoration
            let decorationInfo: DecorationItemInfomation = (items: [layoutDecorationItem(kind: decorationKind)], kind: decorationKind, type: decorationType)
            let layout = Compositional.layoutRegister(section: section, decorationInfo: decorationInfo)

            return layout
        }
        
        /// section的設定 (一格一格滾動 => 自動置中)
        fileprivate static func layoutSection(group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
            return Compositional.layoutSection(group: group, orthogonalScrollingBehavior: .continuousGroupLeadingBoundary)
        }
        
        /// group的大小 (一列需要幾個 / 上下滾動)
        fileprivate static func layoutGroup(height: CGFloat, items: [NSCollectionLayoutItem], rowCount: UInt) -> NSCollectionLayoutGroup {
            return Compositional.layoutGroup(height: height, fractionalWidth: 1.0 / CGFloat(rowCount), items: items, direction: .vertical)
        }
        
        /// item的大小 (跟畫面一樣大)
        fileprivate static func layoutItem(height: CGFloat) -> NSCollectionLayoutItem {
            return Compositional.layoutItem(height: height, fractionalWidth: 1.0)
        }
        
        /// header的大小
        fileprivate static func layoutHeader(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .header) -> NSCollectionLayoutBoundarySupplementaryItem {
            return Compositional.layoutHeader(height: height, ofKind: kind)
        }
        
        /// footer的大小
        fileprivate static func layoutFooter(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .footer) -> NSCollectionLayoutBoundarySupplementaryItem {
            return Compositional.layoutFooter(height: height, ofKind: kind)
        }
        
        /// decoration的大小
        fileprivate static func layoutDecorationItem(kind: Utility.ReusableSupplementaryViewKind = .decoration) -> NSCollectionLayoutDecorationItem {
            return Compositional.layoutDecorationItem(kind: kind)
        }
    }
}

// MARK: - Mix Layout
extension Compositional {
        
    /// 混合型 (TableView + PhotoAlbum)
    final class Mix: NSObject {
        
        /// 輸出Layout (header / footer / decorationItem 選填)
        static func layout<T: UICollectionReusableView>(height: CGFloat, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil, decorationType: T.Type? = nil, rowCount: UInt = 3) -> UICollectionViewCompositionalLayout {
            
            if decorationType == UICollectionReusableView.self { wwPrint("OK") }
            
            let items = [TableView.layoutItem(height: height)]
            let group = TableView.layoutGroup(height: height, items: items)
            let section = TableView.layoutSection(group: group)
            
            if let headerHeight = headerHeight { section.boundarySupplementaryItems.append(TableView.layoutHeader(height: headerHeight)) }
            if let footerHeight = footerHeight { section.boundarySupplementaryItems.append(TableView.layoutFooter(height: footerHeight)) }
                        
            let items2 = [PhotoAlbum.layoutItem(height: height, rowCount: rowCount)]
            let group2 = PhotoAlbum.layoutGroup(height: height, items: items2)
            let section2 = PhotoAlbum.layoutSection(group: group2)
            
            if let headerHeight = headerHeight { section2.boundarySupplementaryItems.append(PhotoAlbum.layoutHeader(height: headerHeight)) }
            if let footerHeight = footerHeight { section2.boundarySupplementaryItems.append(PhotoAlbum.layoutFooter(height: footerHeight)) }
                        
            let layout = UICollectionViewCompositionalLayout { (_section, _environmnet) -> NSCollectionLayoutSection? in
                if (_section % 2 == 0) { return section }
                return section2
            }
            
            return layout
        }
    }
}

// MARK: - 小工具
extension Compositional {
    
    /// item的大小 (寬度由畫面比例去做決定)
    fileprivate static func layoutItem(height: CGFloat, fractionalWidth: CGFloat = 1.0) -> NSCollectionLayoutItem {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionalWidth), heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        return item
    }
    
    /// group的大小 (寬度由畫面比例去做決定)
    fileprivate static func layoutGroup(height: CGFloat, fractionalWidth: CGFloat = 1.0, items: [NSCollectionLayoutItem], direction: Utility.LayoutGroupDirection = .horizontal) -> NSCollectionLayoutGroup {
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionalWidth), heightDimension: .absolute(height))
        let group = (direction == .horizontal) ? NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items) : NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: items)
        
        return group
    }
    
    /// section的設定 (滾動方向)
    fileprivate static func layoutSection(group: NSCollectionLayoutGroup, orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none) -> NSCollectionLayoutSection {
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        return section
    }
    
    /// header的大小 (最上方的View)
    fileprivate static func layoutHeader(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .header) -> NSCollectionLayoutBoundarySupplementaryItem {
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: kind.rawValue, alignment: .top, absoluteOffset: .zero)
        
        return header
    }
    
    /// footer的大小 (最底下的View)
    fileprivate static func layoutFooter(height: CGFloat, ofKind kind: Utility.ReusableSupplementaryViewKind = .footer) -> NSCollectionLayoutBoundarySupplementaryItem {
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: kind.rawValue, alignment: .bottom, absoluteOffset: .zero)
        
        return footer
    }
    
    /// decoration的大小 (背景View)
    fileprivate static func layoutDecorationItem(kind: Utility.ReusableSupplementaryViewKind = .decoration) -> NSCollectionLayoutDecorationItem {
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: kind.rawValue)
        decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return decorationItem
    }
    
    /// 輸出Layout => 註冊 & 加上DecorationItem Layout
    fileprivate static func layoutRegister(section: NSCollectionLayoutSection, decorationInfo: DecorationItemInfomation<UICollectionReusableView>?) -> UICollectionViewCompositionalLayout {
        
        guard let decorationInfo = decorationInfo else { return UICollectionViewCompositionalLayout(section: section) }
    
        let layuot = UICollectionViewCompositionalLayout(section: section._decorationItem(info: decorationInfo))._register(decorationInfo: decorationInfo)
        return layuot
    }
    
    /// 加上DecorationItems
    fileprivate static func sectionDecoration(_ section: NSCollectionLayoutSection, decorationInfo: DecorationItemInfomation<UICollectionReusableView>?) -> NSCollectionLayoutSection {
        
        guard let decorationInfo = decorationInfo else { return section }
        section.decorationItems = decorationInfo.items
        
        return section
    }
}

// MARK: - NSCollectionLayoutSection
extension NSCollectionLayoutSection {
    
    /// 設定decorationItems
    func _decorationItem(info: Compositional.DecorationItemInfomation<UICollectionReusableView>?) -> NSCollectionLayoutSection {
        
        guard let info = info else { return self }
        
        decorationItems = info.items
        return self
    }
}

// MARK: - UICollectionViewCompositionalLayout
extension UICollectionViewCompositionalLayout {
    
    /// 註冊decorationItem
    func _register(decorationInfo: Compositional.DecorationItemInfomation<UICollectionReusableView>?) -> UICollectionViewCompositionalLayout {
        
        guard let decorationInfo = decorationInfo else { return self }
        
        register(decorationInfo.type, forDecorationViewOfKind: decorationInfo.kind.rawValue)
        return self
    }
}
