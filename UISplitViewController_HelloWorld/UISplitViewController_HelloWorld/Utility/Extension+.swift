import UIKit
import PDFKit
import AVKit

// MARK: - Int (class function)
extension Int {
    
    /// 數字位數變換
    /// - 1 => 001
    func _repeatString(count: UInt = 0) -> String {

        let formatType = "%\(String(repeating: "0", count: Int(count)))\(count)d"
        let formatString = String(format: formatType, self)

        return "\(formatString)"
    }
}

// MARK: - Notification (static function)
extension Notification {
    
    /// 註冊通知
    static func _registered(name: Notification.Name, queue: OperationQueue = .main, object: Any? = nil, handler: @escaping ((Notification) -> Void)) {
        NotificationCenter.default.addObserver(forName: name, object: object, queue: queue) { (notification) in handler(notification) }
    }

    /// 發射通知
    static func _post(name: Notification.Name, object: Any? = nil) { NotificationCenter.default.post(name: name, object: object) }

    /// 移除通知
    static func _remove(observer: Any, name: Notification.Name, object: Any? = nil) { NotificationCenter.default.removeObserver(observer, name: name, object: object) }
}

// MARK: - Collection (class function)
extension Collection {

    /// 為 Collection 加上安全取值特性 => nil
    subscript (safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - UISwipeGestureRecognizer
extension UISwipeGestureRecognizer {
    
    /// 滑動手勢產生器 (多指)
    static func _maker(target: Any?, direction: UISwipeGestureRecognizer.Direction, numberOfTouches number: Int = 1, action: Selector?) -> UISwipeGestureRecognizer {
        
        let recognizer = UISwipeGestureRecognizer(target: target, action: action)
        
        recognizer.direction = direction
        recognizer.numberOfTouchesRequired = number

        return recognizer
    }
}

// MARK: - UIScreen (static function / …)
extension UIScreen {
        
    /// 回傳主畫面大小訊息
    /// - UIKit
    static func _mainBounds() -> UtilitySystem.ScreenBoundsInfomation {
        return (width: main.bounds.width, height: main.bounds.height, scale: main.scale)
    }
}

// MARK: - UIView (class function)
extension UIView {
 
    /// 加上手勢動作功能
    /// - Array
    func _addGestureRecognizers(with recognizers: [UIGestureRecognizer]) {
        
        recognizers.forEach { (_recognizer) in
            addGestureRecognizer(_recognizer)
        }
    }
}

// MARK: - UIScrollView (class function)
extension UIScrollView {
        
    /// 滾動時讓View放大縮小的Frame (向下拉的時候)
    /// - isUnderBarView => 在navigationBar的下方
    /// - contentInsetAdjustmentBehavior = .never
    func _navigationItemHeaderViewZoomFrame(_ navigationController: UINavigationController?, headerView: UIView?, isUnderBarView: Bool = true) -> CGRect {
        
        guard let headerView = headerView,
              let navigationBarFrame = navigationController?.navigationBar._rootView?.frame
        else {
            return .zero
        }
        
        guard let barHeight = Optional.some(isUnderBarView ? navigationBarFrame.height : 0),
              let offsetY = Optional.some(contentOffset.y),
              offsetY < barHeight,
              var newFrame = Optional.some(headerView.frame)
        else {
            return headerView.frame
        }
                
        newFrame.origin.y = offsetY
        newFrame.size.height = abs(offsetY)
        
        return newFrame
    }
}

// MARK: - UITableView (class function)
extension UITableView {
    
    /// 取得UITableViewCell
    /// - let cell = tableview._reusableCell(at: indexPath) as MyTableViewCell
    func _reusableCell<T: CellReusable>(at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else { fatalError("UITableViewCell Error") }
        return cell
    }
}

// MARK: - PDFView (class function)
extension PDFView {
    
    /// 設定背景色
    func _backgroundColor(_ color: UIColor) -> PDFView {
        subviews.first?.backgroundColor = color
        return self
    }

    /// 設定觀看模式
    func _displayMode(_ mode: PDFDisplayMode = .singlePageContinuous, isAutoScales: Bool = true) -> PDFView {
        displayMode = mode
        autoScales = isAutoScales
        return self
    }
    
    /// 讀取文件
    /// - 回傳頁數
    func _document(url: URL, result: @escaping (Result<Int, Error>) -> Void) {
        
        guard let document = PDFDocument(url: url) else { result(.failure(Utility.MyError.unknown))  ;return }
        self.document = document
        result(.success(document.pageCount))
    }
}

// MARK: - UINavigationBar (class variable)
extension UINavigationBar {
    
    /// 可以變成透明的barView
    /// - UIScorllView應用
    var _rootView: UIView? { return _firstSubView() }
}

// MARK: - UINavigationBar (private class function)
extension UINavigationBar {
    
    /// 取得第一個SubView
    private func _firstSubView() -> UIView? { return subviews.first }
}

// MARK: - UIActivityViewController (static function)
extension UIActivityViewController {
    
    /// 產生ActivityViewController分享功能
    /// - anchorItem為iPad使用
    static func _maker(activityItems: [Any], applicationActivities: [UIActivity]? = nil, tintColor: UIColor = .white, anchorItem: UIBarButtonItem? = nil) -> UIActivityViewController {
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.view.tintColor = tintColor
        activityViewController.popoverPresentationController?.barButtonItem = anchorItem

        return activityViewController
    }
}

// MARK: - UINavigationController (class function)
extension UINavigationController {

    /// 設定NavigationBar顯示 / 隱藏
    func _navigationBarHidden(_ isHidden: Bool, animated: Bool = true) {
        setNavigationBarHidden(isHidden, animated: animated)
    }
}

// MARK: - UIPrintInteractionController (static function)
extension UIPrintInteractionController {
    
    /// 產生列印的UIPrintInteractionController - for Data
    /// - .present(animated: true, completionHandler: nil)
    static func _result(printingData: Data?, jobName: String, orientation: UIPrintInfo.Orientation = .landscape) -> Result<UIPrintInteractionController, Utility.MyError> {
        
        guard let printingData = printingData else { return .failure(.isEmpty) }
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        
        printInfo.outputType = .general
        printInfo.jobName = jobName
        printInfo.orientation = orientation

        printController.printInfo = printInfo
        printController.printingItem = printingData
        
        return .success(printController)
    }
}

// MARK: - AVRoutePickerView
extension AVRoutePickerView {
    
    /// 產生AirPlay的View
    /// - 可以加在 barButtonItem.customView = AVRoutePickerView._customView()
    static func _customView(frame: CGRect = .zero, tintColor: UIColor = .blue, activeTintColor: UIColor = .red) -> AVRoutePickerView {
        
        let routePickerView = AVRoutePickerView(frame: frame)
        
        routePickerView.tintColor = tintColor
        routePickerView.activeTintColor = activeTintColor

        return routePickerView
    }
}
