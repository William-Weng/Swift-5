//
//  Utility.swift
//  CompositionalLayout_TableView
//
//  Created by William.Weng on 2020/9/14.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

// MARK: - 自定義的Print
public func wwPrint<T>(_ msg: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        Swift.print("🚩 \((file as NSString).lastPathComponent)：\(line) - \(method) \n\t ✅ \(msg)")
    #endif
}

// MARK: - Utility (單例)
final class Utility: NSObject {
    static let shared = Utility()
    private override init() {}
}

// MARK: - enum
extension Utility {
    
    /// UICollectionReusableView的Kind
    enum ReusableSupplementaryViewKind: String {
        
        case none = "UICollectionNone"
        case header = "UICollectionElementKindSectionHeader"
        case footer = "UICollectionElementKindSectionFooter"
        case badge = "UICollectionElementKindSectionBadge"
        case decoration = "UICollectionElementKindDecoration"
    }
    
    /// NSCollectionLayoutGroup的滾動方向 (垂直 / 水平)
    enum LayoutGroupDirection {
        case horizontal
        case vertical
    }
}
