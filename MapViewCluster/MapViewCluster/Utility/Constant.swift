//
//  Constant.swift
//  Example
//
//  Created by William.Weng on 2022/12/28.
//

import MapKit

enum MapKitVisibleScaleType {
    case meters(_ distance: CLLocationDistance)
    case delta(_ degrees: CLLocationDegrees)
}

enum PinGlyphType {
    case text(_ text: String?)
    case image(_ image: UIImage?, _ selectedImage: UIImage?)
}

enum MapKitOverlayType {
    case circle(_ radius: CLLocationDistance)
}

// MARK: - 可重複使用的AnnotationView
protocol PinViewReusable: AnyObject {
    
    static var identifier: String { get }
    
    var annotation: MKAnnotation? { get }

    func configure(with annotation: MKAnnotation, clusteringIdentifier: String?, displayPriority: MKFeatureDisplayPriority)
}

// MARK: - 預設 identifier = class name (初值)
extension PinViewReusable {
    
    static var identifier: String { return String(describing: Self.self) }
    
    var annotation: MKAnnotation? { nil }
    
    func configure(with annotation: MKAnnotation, clusteringIdentifier: String? = nil, displayPriority: MKFeatureDisplayPriority = .defaultLow) {}
}

/// [比對用的NSPredicate](https://zh-tw.coderbridge.com/series/01d31194cb3c428d9ca2575c91e8b997/posts/11802227e6ad4e52b027d66f8f527f03)
/// - Predicate.between(from: 100, to: 50).build().evaluate(with: 90)
enum Predicate {
    
    case matches(regex: String)                 // [正則表達式 (正規式)](https://swift.gg/2019/11/19/nspredicate-objective-c/)
    case between(from: Any, to: Any)            // 區間比對 (from ~ to)
    case contain(in: Set<AnyHashable>)          // 範圍比對 (33 in [22, 33, 44] => true)
    case contains(with: String)                 // 中間包含文字 ("333GoGo3333" 包含 "GoGo")
    case begin(with: String)                    // 開頭包含文字 ("This is a Student." 開頭是 "This")
    case end(with: String)                      // 結尾包含文字 ("This is a Student." 結尾是 "Student")
    case outOfRange(from: Any, to: Any)         // 範圍之外

    /// [產生NSPredicate](https://www.jianshu.com/p/bfdacbdf37a7)
    /// - Returns: NSPredicate
    func build() -> NSPredicate {
        switch self {
        case .matches(let regex): return NSPredicate(format: "SELF MATCHES %@", regex)
        case .between(let from, let to): return NSPredicate(format: "SELF BETWEEN { \(from), \(to) }")
        case .contain(let set): return NSPredicate(format: "SELF IN %@", set)
        case .contains(let word): return NSPredicate(format: "SELF CONTAINS[cd] %@", word)
        case .begin(let word): return NSPredicate(format: "SELF BEGINSWITH[cd] %@", word)
        case .end(let word): return NSPredicate(format: "SELF ENDSWITH[cd] %@", word)
        case .outOfRange(let from, let to): return NSPredicate(format: "(SELF > \(from)) OR (SELF < \(to))")
        }
    }
}
