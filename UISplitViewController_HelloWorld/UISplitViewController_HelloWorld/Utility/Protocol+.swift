import UIKit

// MARK: - 可重複使用的Cell (UITableViewCell / UICollectionViewCell)
protocol CellReusable: class {
    
    static var identifier: String { get }           /// Cell的Identifier
    var indexPath: IndexPath { get }                /// Cell的IndexPath
    
    /// Cell的相關設定
    func configure(with indexPath: IndexPath)
}

// MARK: - 預設 identifier = class name (初值)
extension CellReusable {
    static var identifier: String { return String(describing: Self.self) }
    var indexPath: IndexPath { return [] }
}

// MARK: - 設定狀態列的顯示或隱藏
// - override var prefersStatusBarHidden: Bool { return isStatusBarHidden }
protocol StatusBarHideable where Self: UIViewController {
    var isStatusBarHidden: Bool { get set }
}

