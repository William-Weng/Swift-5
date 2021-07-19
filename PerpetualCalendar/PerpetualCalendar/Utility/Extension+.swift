//
//  Extension+.swift
//  PerpetualCalendar
//
//  Created by William.Weng on 2021/7/19.
//

import UIKit

// MARK: - Int (class function)
extension Int {
    
    /// 轉成CGFloat
    /// - Returns: CGFloat
    func _CGFloat() -> CGFloat { return CGFloat(self) }
    
    /// 轉成Double
    /// - Returns: Double
    func _Double() -> Double { return Double(self) }
}

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

// MARK: - String (class function)
extension String {
    
    /// 將"2020-07-08 16:36:31 +0800" => Date()
    /// - Parameter dateFormat: 時間格式
    /// - Returns: Date?
    func _date(dateFormat: Constant.DateFormat = .short) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue

        return dateFormatter.date(from: self)
    }
}

// MARK: - UIStoryboard (static function)
extension UIStoryboard {
    
    /// 由UIStoryboard => ViewController
    /// - Parameters:
    ///   - name: Storyboard的名稱 => Main.storyboard
    ///   - storyboardBundleOrNil: Bundle名稱
    ///   - identifier: ViewController的代號 (記得要寫)
    /// - Returns: T (泛型) => UIViewController
    static func _instantiateViewController<T: UIViewController>(name: String = "Main", bundle storyboardBundleOrNil: Bundle? = nil, identifier: String = String(describing: T.self)) -> T {
        
        let viewController: T
        
        if #available(iOS 13.0, *) {
            viewController = Self(name: name, bundle: storyboardBundleOrNil).instantiateViewController(identifier: identifier) as T
        } else {
            viewController = Self(name: name, bundle: storyboardBundleOrNil).instantiateViewController(withIdentifier: identifier) as! T
        }
        
        return viewController
    }
}

// MARK: - Date (class function)
extension Date {
    
    /// 將UTC時間 => 該時區的時間
    /// - 2020-07-07 16:08:50 +0800
    /// - Parameters:
    ///   - dateFormat: 時間格式
    ///   - identifier: 區域辨識碼
    /// - Returns: String?
    func _localTime(with dateFormat: Constant.DateFormat = .full, timeZone identifier: Constant.TimeZoneIdentifier) -> String? { return _localTime(with: dateFormat, timeZone: identifier.rawValue) }
    
    /// 將UTC時間 => 該時區的時間
    /// - 2020-07-07 16:08:50 +0800
    /// - Parameters:
    ///   - dateFormat: 時間格式
    ///   - identifier: 區域辨識碼
    /// - Returns: String?
    func _localTime(with dateFormat: Constant.DateFormat = .full, timeZone identifier: String) -> String? {
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = TimeZone(identifier: identifier)

        return dateFormatter.string(from: self)
    }
    
    /// [增加日期 => 年 / 月 / 日](https://areckkimo.medium.com/用uipageviewcontroller實作萬年曆-76edaac841e1)
    /// - Parameters:
    ///   - component:
    ///   - value: 年(.year) / 月(.month) / 日(.day)
    ///   - calendar: 當地的日曆基準
    /// - Returns: Date?
    func _adding(component: Calendar.Component = .day, value: Int, for calendar: Calendar = .current) -> Date? {
        return calendar.date(byAdding: component, value: value, to: self)
    }
    
    /// [比較日期文字是否相等？](https://areckkimo.medium.com/用uipageviewcontroller實作萬年曆-76edaac841e1)
    /// - Parameters:
    ///   - anotherDate: 另一個要比較的日期
    ///   - timeZone: 時區
    ///   - dateFormat: 要比較的日期格式 (不一定要比完整的日期)
    /// - Returns: Bool
    func _compare(equal anotherDate: Date?, with dateFormat: Constant.DateFormat = .full, timeZone: Constant.TimeZoneIdentifier = .Asia_Taipei) -> Bool {
        
        guard let thisDate = self._localTime(with: dateFormat, timeZone: timeZone),
              let anotherDate = anotherDate?._localTime(with: dateFormat, timeZone: timeZone)
        else {
            return false
        }
        
        return thisDate == anotherDate
    }
    
    /// 取得當月的第一天
    /// - Parameter calendar: 當地的日曆基準
    /// - Returns: Date?
    func _firstDayOfMonth(for calendar: Calendar = .current) -> Date? {
        let dateComponents = calendar.dateComponents([.month, .year], from: self)
        return calendar.date(from: dateComponents)
    }
    
    /// 當天是當月的第幾週？
    /// - 有可能會發生 2021/7/1 => 6月的第五週
    /// - Returns: Int
    func _weekday() -> Int { return self._component(.weekday) }
    
    /// 時間其中一位的數值 => 年？月？日？
    /// - Returns: Int
    /// - Parameters:
    ///   - component: 單位 => .day
    ///   - calendar: 當地的日曆基準
    func _component(_ component: Calendar.Component = .day, for calendar: Calendar = .current) -> Int {
        return calendar.component(component, from: self)
    }
}

// MARK: - UITapGestureRecognizer
extension UITapGestureRecognizer {
    
    /// 輕點手勢產生器 (多指)
    /// - Parameters:
    ///   - target: 要設定的位置
    ///   - numberOfTouchesRequired: 需要幾指去點才有反應？
    ///   - numberOfTapsRequired: 需要要點幾下？
    ///   - action: 點下去要做什麼？
    /// - Returns: UITapGestureRecognizer
    static func _build(target: Any?, numberOfTouchesRequired: Int = 1, numberOfTapsRequired: Int = 1, action: Selector?) -> UITapGestureRecognizer {
        
        let recognizer = UITapGestureRecognizer(target: target, action: action)
        
        recognizer.numberOfTapsRequired = numberOfTapsRequired
        recognizer.numberOfTouchesRequired = numberOfTouchesRequired
        
        return recognizer
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    /// 設定UIViewController透明背景 (當Alert用)
    /// - Present Modally
    /// - Parameter backgroundColor: 背景色
    func _transparent(_ backgroundColor: UIColor = .clear) {
        self._modalStyle(backgroundColor, transitionStyle: .crossDissolve, presentationStyle: .overCurrentContext)
    }
    
    /// 設定UIViewController透明背景 (當Alert用)
    /// - Parameters:
    ///   - backgroundColor: 背景色
    ///   - transitionStyle: 轉場的Style
    ///   - presentationStyle: 彈出的Style
    func _modalStyle(_ backgroundColor: UIColor = .white, transitionStyle: UIModalTransitionStyle = .coverVertical, presentationStyle: UIModalPresentationStyle = .currentContext) {
        self.view.backgroundColor = backgroundColor
        self.modalPresentationStyle = presentationStyle
        self.modalTransitionStyle = transitionStyle
    }
}

// MARK: - UIPickerView (static function)
extension UIPickerView {
    
    /// 自定義鍵盤
    /// - UITextField => .inputView / .inputAccessoryView / .becomeFirstResponder()
    /// - Parameters:
    ///   - delegateAndDataSource: UIPickerViewDelegate
    ///   - doneAction: 按下確定時的動作
    ///   - cancelAction: 按下取消時的動作
    /// - Returns: Constant.CustomKeyborad
    static func _build(delegateAndDataSource: UIPickerViewDelegate & UIPickerViewDataSource, doneAction: Selector?, cancelAction: Selector?) -> Constant.CustomKeyborad {

        let keyboardView = UIPickerView(frame: UIDatePicker.appearance().frame)
        let toolBarSize = CGSize(width: 320, height: 44)
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: toolBarSize))
        
        let doneButtonItem = UIBarButtonItem(title: "確定", style: .done, target: delegateAndDataSource, action: doneAction)
        let flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: delegateAndDataSource, action: cancelAction)
        
        keyboardView.delegate = delegateAndDataSource
        keyboardView.dataSource = delegateAndDataSource
        
        toolBar.items = [cancelButtonItem, flexibleSpaceButtonItem, doneButtonItem]

        return (keyboardView, toolBar)
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
}

// MARK: - UIPageViewController (class function)
extension UIPageViewController {
    
    /// 初始化Protocal
    /// - Parameter this: UIPageViewControllerDelegate & UIPageViewControllerDataSource
    func _delegateAndDataSource(with this: UIPageViewControllerDelegate & UIPageViewControllerDataSource) {
        self.delegate = this
        self.dataSource = this
    }
}
