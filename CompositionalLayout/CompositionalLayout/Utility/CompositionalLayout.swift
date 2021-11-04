//
//  CompositionalLayout.swift
//  CompositionalLayout
//
//  Created by William.Weng on 2021/11/2.
//

import UIKit
import WWPrint

final class CompositionalLayout: NSObject {
    
    static let ww = WW()
    
    final class WW: NSObject {
        
        typealias ItemSetting = (width: NSCollectionLayoutDimension?, height: NSCollectionLayoutDimension?, contentInsets: NSDirectionalEdgeInsets?, badgeSetting: BadgeSetting?)
        typealias GroupSetting = (width: NSCollectionLayoutDimension?, height: NSCollectionLayoutDimension?, interItemSpacing: NSCollectionLayoutSpacing?, scrollingDirection: NSCollectionLayoutDirection?)
        typealias SectionSetting = (scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?, contentInsets: NSDirectionalEdgeInsets?)
        typealias HeaderSetting = (width: NSCollectionLayoutDimension?, height: NSCollectionLayoutDimension?, kind: ReusableSupplementaryViewKind?, alignment: NSRectAlignment?, absoluteOffset: CGPoint?)
        typealias FooterSetting = HeaderSetting
        typealias DecorationSetting = (kind: ReusableSupplementaryViewKind?, contentInsets: NSDirectionalEdgeInsets?)
        typealias BadgeSetting = (key: String, size: ItemSize, zIndex: Int, containerAnchor: AnchorSetting, itemAnchor: AnchorSetting)
        typealias ItemSize = (width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension)
        typealias AnchorSetting = (edges: NSDirectionalRectEdge, absoluteOffset: CGPoint)
        
        /// 滾動的方向
        enum NSCollectionLayoutDirection {
            case horizontal
            case vertical
            case custom
        }
        
        /// UICollectionReusableView的Kind
        enum ReusableSupplementaryViewKind: CustomStringConvertible {
            
            var description: String { return toString() }
            
            case none
            case header
            case footer
            case badge(key: String)
            case decoration
            
            /// 轉換成對應的文字
            /// - Returns: String
            func toString() -> String {
                switch self {
                case .none: return "UICollectionNone"
                case .header: return "UICollectionElementKindSectionHeader"
                case .footer: return "UICollectionElementKindSectionFooter"
                case .badge(let key): return "UICollectionElementKindSectionBadge-\(key)"
                case .decoration: return "UICollectionElementKindDecoration"
                }
            }
        }
        
        private var itemSettings: [ItemSetting] = []
        private var groupSetting: GroupSetting = (nil, nil ,nil, nil)
        private var sectionSetting: SectionSetting = (nil, nil)
        private var headerSetting: HeaderSetting = (nil, nil, nil, nil, nil)
        private var footerSetting: FooterSetting = (nil, nil, nil, nil, nil)
        private var decorationSetting: DecorationSetting = (nil, nil)
    }
}

// MARK: - CompositionalLayout.WW (class function)
extension CompositionalLayout.WW {
        
    /// [設定item的size (可以有很多個)](https://www.donnywals.com/using-compositional-collection-view-layouts-in-ios-13/)
    /// - Parameters:
    ///   - width: [NSCollectionLayoutDimension](https://www.raywenderlich.com/5436806-modern-collection-views-with-compositional-layouts)
    ///   - height: [NSCollectionLayoutDimension](https://www.raywenderlich.com/9477-uicollectionview-tutorial-reusable-views-selection-and-reordering)
    ///   - contentInsets: [NSDirectionalEdgeInsets?](https://medium.com/flawless-app-stories/all-what-you-need-to-know-about-uicollectionviewcompositionallayout-f3b2f590bdbe)
    ///   - badgeSetting: [小紅點的相關設定](https://stackoverflow.com/questions/60112393/section-header-zindex-in-uicollectionview-compositionallayout-ios-13)
    /// - Returns: [Self](https://medium.com/@Anantha1992/stretchable-header-view-in-uicollectionview-swift-5-ios-a14a25dcd383)
    func addItem(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, contentInsets: NSDirectionalEdgeInsets? = nil, badgeSetting: BadgeSetting? = nil) -> Self {
        
        let setting: ItemSetting = (width, height, contentInsets, badgeSetting)
        itemSettings.append(setting)
        
        return self
    }
    
    /// [設定group的size (只會有一個)](https://www.jianshu.com/p/40868928a1cf)
    /// - Parameters:
    ///   - width: [NSCollectionLayoutDimension](https://www.appcoda.com.tw/compositional-layout/)
    ///   - height: [NSCollectionLayoutDimension](https://ali-akhtar.medium.com/uicollection-compositional-layout-part-3-7d6d66806979)
    ///   - interItemSpacing: NSCollectionLayoutSpacing?
    ///   - scrollingDirection: NSCollectionLayoutDirection
    /// - Returns: Self
    func setGroup(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, interItemSpacing: NSCollectionLayoutSpacing? = nil, scrollingDirection: NSCollectionLayoutDirection) -> Self {
        
        groupSetting.width = width
        groupSetting.height = height
        groupSetting.interItemSpacing = interItemSpacing
        groupSetting.scrollingDirection = scrollingDirection
        
        return self
    }
    
    /// 設定section的size (只會有一個)
    /// - Parameters:
    ///   - scrollingBehavior: 滾動的方向
    ///   - contentInsets: NSDirectionalEdgeInsets
    /// - Returns: Self
    func setSection(scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none, contentInsets: NSDirectionalEdgeInsets) -> Self {
        
        sectionSetting.scrollingBehavior = scrollingBehavior
        sectionSetting.contentInsets = contentInsets
        
        return self
    }
    
    /// header的大小 (最上方的View)
    func setHeader(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, absoluteOffset: CGPoint = .zero) -> Self {
        
        headerSetting.width = width
        headerSetting.height = height
        headerSetting.absoluteOffset = absoluteOffset
        headerSetting.alignment = .top
        headerSetting.kind = .header
        
        return self
    }
    
    /// footer的大小 (最下方的View)
    func setFooter(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, absoluteOffset: CGPoint = .zero) -> Self {
        
        footerSetting.width = width
        footerSetting.height = height
        footerSetting.absoluteOffset = absoluteOffset
        footerSetting.alignment = .bottom
        footerSetting.kind = .footer
        
        return self
    }
    
    /// 設定背景圖的View
    /// - Parameters:
    ///   - contentInsets: NSDirectionalEdgeInsets
    /// - Returns: NSCollectionLayoutDecorationItem
    func setDecoration(contentInsets: NSDirectionalEdgeInsets = .zero) -> Self {
        
        decorationSetting.kind = .decoration
        decorationSetting.contentInsets = contentInsets
        
        return self
    }
    
    /// 產生UICollectionViewCompositionalLayout
    /// - Returns: UICollectionViewCompositionalLayout?
    func build() -> UICollectionViewCompositionalLayout? {
        
        defer { cleanAllSetting() }
        
        guard let subItems = subItemsMaker(),
              let group = groupMaker(with: groupSetting, subitems: subItems),
              let section = sectionMaker(with: sectionSetting, group: group)
        else {
            return nil
        }
        
        if let header = headerMaker(with: headerSetting) { section.boundarySupplementaryItems.append(header) }
        if let footer = footerMaker(with: footerSetting) { section.boundarySupplementaryItems.append(footer) }
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - CompositionalLayout.WW (private class function)
extension CompositionalLayout.WW {
    
    /// [NSCollectionLayoutSize] => [NSCollectionLayoutItem]
    /// - Returns: [NSCollectionLayoutItem]?
    private func subItemsMaker() -> [NSCollectionLayoutItem]? {
        
        guard !itemSettings.isEmpty else { return nil }
        
        let items = itemSettings.compactMap { (setting) -> NSCollectionLayoutItem? in
            
            guard let width = setting.width,
                  let height = setting.height
            else {
                return nil
            }
            
            let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
            var item: NSCollectionLayoutItem

            if let badgeItem = badgeMaker(setting: setting.badgeSetting) {
                item = NSCollectionLayoutItem(layoutSize: size, supplementaryItems: [badgeItem])
            } else {
                item = NSCollectionLayoutItem(layoutSize: size)
            }
            
            if let contentInsets = setting.contentInsets { item.contentInsets = contentInsets }
            
            return item
        }
        
        return items
    }
    
    /// 產生小紅點 => NSCollectionLayoutSupplementaryItem
    /// - Parameter setting: BadgeSetting?
    /// - Returns: NSCollectionLayoutSupplementaryItem?
    private func badgeMaker(setting: BadgeSetting?) -> NSCollectionLayoutSupplementaryItem? {
        
        guard let setting = setting else { return nil }
        
        let kind = "\(ReusableSupplementaryViewKind.badge(key: setting.key))"
        let size = NSCollectionLayoutSize(widthDimension: setting.size.width, heightDimension: setting.size.height)
        let containerAnchor = NSCollectionLayoutAnchor(edges: setting.containerAnchor.edges, absoluteOffset: setting.containerAnchor.absoluteOffset)
        let itemAnchor = NSCollectionLayoutAnchor(edges: setting.itemAnchor.edges, absoluteOffset: setting.itemAnchor.absoluteOffset)
        let item = NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: kind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
        
        item.zIndex = setting.zIndex
        return item
    }
    
    /// [NSCollectionLayoutItem] => NSCollectionLayoutGroup
    /// - Parameter setting: GroupSetting
    /// - Parameter subitems: [NSCollectionLayoutItem]
    /// - Returns: NSCollectionLayoutGroup?
    private func groupMaker(with setting: GroupSetting, subitems: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup? {
        
        guard let width = setting.width,
              let height = setting.height,
              let scrollingDirection = setting.scrollingDirection,
              let layoutSize = Optional.some(NSCollectionLayoutSize(widthDimension: width, heightDimension: height))
        else {
            return nil
        }
        
        let group: NSCollectionLayoutGroup
        
        switch scrollingDirection {
        case .horizontal: group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: subitems)
        case .vertical: group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, subitems: subitems)
        case .custom: fatalError()
        }
        
        group.interItemSpacing = groupSetting.interItemSpacing
        
        return group
    }
    
    /// NSCollectionLayoutGroup => NSCollectionLayoutSection
    /// - Parameter setting: SectionSetting
    /// - Parameter group: NSCollectionLayoutGroup
    /// - Returns: NSCollectionLayoutSection?
    private func sectionMaker(with setting: SectionSetting, group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection? {
        
        guard let scrollingBehavior = setting.scrollingBehavior,
              let contentInsets = setting.contentInsets
        else {
            return nil
        }
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = scrollingBehavior
        section.contentInsets = contentInsets
        
        if let decoration = decorationMaker() { section.decorationItems = [decoration] }

        return section
    }
    
    /// 將header的設定 => NSCollectionLayoutBoundarySupplementaryItem
    /// - Parameter setting: HeaderSetting
    /// - Returns: NSCollectionLayoutBoundarySupplementaryItem?
    private func headerMaker(with setting: HeaderSetting) -> NSCollectionLayoutBoundarySupplementaryItem? {
        
        guard let width = setting.width,
              let height = setting.height,
              let absoluteOffset = setting.absoluteOffset,
              let alignment = setting.alignment,
              let kind = setting.kind
        else {
            return nil
        }
        
        let headerSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "\(kind)", alignment: alignment, absoluteOffset: absoluteOffset)
        
        return header
    }
    
    /// 將footer的設定 => NSCollectionLayoutBoundarySupplementaryItem
    /// - Parameter setting: HeaderSetting
    /// - Returns: NSCollectionLayoutBoundarySupplementaryItem?
    private func footerMaker(with setting: FooterSetting) -> NSCollectionLayoutBoundarySupplementaryItem? { return headerMaker(with: setting) }
    
    /// 將背景圖的設定 => NSCollectionLayoutDecorationItem
    /// - Returns: NSCollectionLayoutDecorationItem?
    private func decorationMaker() -> NSCollectionLayoutDecorationItem? {
        
        guard let kind = decorationSetting.kind,
              let contentInsets = decorationSetting.contentInsets
        else {
            return nil
        }
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "\(kind)")
        decorationItem.contentInsets = contentInsets
        
        return decorationItem
    }
    
    /// 清除所有設定
    private func cleanAllSetting() {
        itemSettings = []
        groupSetting = (nil, nil ,nil, nil)
        sectionSetting = (nil, nil)
        headerSetting = (nil, nil, nil, nil, nil)
        footerSetting = (nil, nil, nil, nil, nil)
        decorationSetting = (nil, nil)
    }
}
