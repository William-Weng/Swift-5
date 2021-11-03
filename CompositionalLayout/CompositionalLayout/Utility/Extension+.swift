//
//  Extension+.swift
//  CompositionalLayout
//
//  Created by William.Weng on 2021/11/2.
//

import UIKit

// MARK: - Collection (override class function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - Collection (class function)
extension Collection where Self == [ClosedRange<Int>] {
    
    /// [產生重複測試用的Array](https://swiftdoc.org/v3.1/type/closedrange/)
    /// - [1...100]._repeating(text: " - 測試用") => 1 - 測試用 / 2 - 測試用 / ...
    /// - Parameter text: 要重複的文字
    /// - Returns: [String]
    func _repeating(text: String? = nil) -> [String] {
        
        var result = [String]()
        
        guard let range = self.first else { return result }
        
        for index in range.lowerBound...range.upperBound {
            
            if let text = text {
                result.append("\(index)\(text)")
            } else {
                result.append("\(index)")
            }
        }
        
        return result
    }
}

// MARK: - UICollectionView (class function)
extension UICollectionView {
    
    /// 初始化Protocal
    /// - Parameter this: UICollectionViewDelegate & UICollectionViewDataSource
    func _delegateAndDataSource(with this: UICollectionViewDelegate & UICollectionViewDataSource) {
        self.delegate = this
        self.dataSource = this
    }
    
    /// 取得UICollectionViewCell
    /// - let cell = collectionView._reusableCell(at: indexPath) as MyCollectionViewCell
    /// - Parameter indexPath: IndexPath
    /// - Returns: 符合CellReusable的Cell
    func _reusableCell<T: CellReusable>(at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else { fatalError("UICollectionViewCell Error") }
        return cell
    }
    
    /// 取得UICollectionReusableView
    /// - let header = collectionView._reusableHeader(at: indexPath, forKind = .header) as MyCollectionReusableHeader
    /// - Parameters:
    ///   - indexPath: IndexPath
    ///   - kind: Constant.ReusableSupplementaryViewKind
    /// - Returns: 符合CellReusable的ReusableView
    func _reusableSupplementaryView<T: CellReusable>(at indexPath: IndexPath, ofKind kind: CompositionalLayout.WW.ReusableSupplementaryViewKind) -> T where T: UICollectionReusableView {
        guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: "\(kind)", withReuseIdentifier: T.identifier, for: indexPath) as? T else { fatalError("UICollectionReusableView Error") }
        return supplementaryView
    }
    
    /// 註冊Cell (使用xib / code)
    /// - Parameters:
    ///   - cellClass: 符合CellReusable的Cell
    ///   - kind: String
    func  _registerSupplementaryView<T: CellReusable>(cellClass: T.Type, ofKind kind: CompositionalLayout.WW.ReusableSupplementaryViewKind) {
        register(T.self, forSupplementaryViewOfKind: "\(kind)", withReuseIdentifier: T.identifier)
    }
}

// MARK: - UICollectionViewLayout (class function)
extension UICollectionViewCompositionalLayout {
        
    func _register<T: CellReusable>(with collectionView: UICollectionView, supplementaryViewClass: T.Type, ofKind kind: CompositionalLayout.WW.ReusableSupplementaryViewKind) -> Self {
        collectionView._registerSupplementaryView(cellClass: supplementaryViewClass, ofKind: kind)
        return self
    }
    
    func _register(with viewClass: AnyClass?, ofKind kind: CompositionalLayout.WW.ReusableSupplementaryViewKind) -> Self {
        self.register(viewClass, forDecorationViewOfKind: "\(kind)")
        return self
    }
}
