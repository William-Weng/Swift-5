//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2022/12/28.
//

import UIKit
import MapKit
import WWPrint

// MARK: - Encodable (class function)
extension Encodable {
    
    /// Class => JSON Data
    /// - Returns: Data?
    func _jsonData() -> Data? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        return jsonData
    }
    
    /// Class => JSON String
    func _jsonString() -> String? {
        guard let jsonData = self._jsonData() else { return nil }
        return jsonData._string()
    }
    
    /// Class => JSON Object
    /// - Returns: Any?
    func _jsonObject() -> Any? {
        guard let jsonData = self._jsonData() else { return nil }
        return jsonData._jsonObject()
    }
}

// MARK: - String (class Overloading)
extension String {
    
    /// String => Data
    /// - Parameters:
    ///   - encoding: 字元編碼
    ///   - isLossyConversion: 失真轉換
    /// - Returns: Data?
    func _data(using encoding: String.Encoding = .utf8, isLossyConversion: Bool = false) -> Data? {
        let data = self.data(using: encoding, allowLossyConversion: isLossyConversion)
        return data
    }
    
    /// JSON String => JSON Object
    /// - Parameters:
    ///   - encoding: 字元編碼
    ///   - options: JSON序列化讀取方式
    /// - Returns: Any?
    func _jsonObject(encoding: String.Encoding = .utf8, options: JSONSerialization.ReadingOptions = .allowFragments) -> Any? {
        
        guard let data = self._data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: options)
        else {
            return nil
        }
        
        return jsonObject
    }
}

// MARK: - Data (class Overloading)
extension Data {

    /// Data => 字串
    /// - Parameter encoding: 字元編碼
    /// - Returns: String?
    func _string(using encoding: String.Encoding = .utf8) -> String? {
        return String(bytes: self, encoding: encoding)
    }
    
    /// Data => Class
    /// - Parameter type: 要轉型的Type => 符合Decodable
    /// - Returns: T => 泛型
    func _class<T: Decodable>(type: T.Type) -> T? {
        let modelClass = try? JSONDecoder().decode(type.self, from: self)
        return modelClass
    }
}

// MARK: - UIColr (init function)
extension UIColor {
    
    /// UIColor(red: 255, green: 255, blue: 255, alpha: 255)
    /// - Parameters:
    ///   - red: 紅色 => 0~255
    ///   - green: 綠色 => 0~255
    ///   - blue: 藍色 => 0~255
    ///   - alpha: 透明度 => 0~255
    convenience init(red: Int, green: Int, blue: Int, alpha: Int) { self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0) }
    
    /// UIColor(rgba: 0xFFFFFFFF)
    /// - Parameter rgba: 顏色的16進位值數字
    convenience init(rgba: Int) { self.init(red: (rgba >> 24) & 0xFF, green: (rgba >> 16) & 0xFF, blue: (rgba >> 8) & 0xFF, alpha: (rgba) & 0xFF) }
    
    /// UIColor(rgba: #FFFFFFFF)
    /// - Parameter rgba: 顏色的16進位值字串
    convenience init(rgba: String) {
        
        let ruleRGBA = "^#[0-9A-Fa-f]{8}$"
        let predicateRGBA = Predicate.matches(regex: ruleRGBA).build()
        
        guard predicateRGBA.evaluate(with: rgba),
              let string = rgba.split(separator: "#").last,
              let number = Int.init(string, radix: 16)
        else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0); return
        }
        
        self.init(rgba: number)
    }
}

// MARK: - Array (class function)
extension Array {
    
    /// Array => JSON Data
    /// - ["name","William"] => ["name","William"] => 5b226e616d65222c2257696c6c69616d225d
    /// - Returns: Data?
    func _jsonData(options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        return JSONSerialization._data(with: self, options: options)
    }
    
    /// Array => JSON Data => [T]
    /// - Parameter type: 要轉換成的Array類型
    /// - Returns: [T]?
    func _jsonClass<T: Decodable>(for type: [T].Type) -> [T]? {
        let array = self._jsonData()?._class(type: type.self)
        return array
    }
}

// MARK: - Dictionary (class function)
extension Dictionary {
    
    /// Dictionary => JSON Data
    /// - ["name":"William"] => {"name":"William"} => 7b226e616d65223a2257696c6c69616d227d
    /// - Returns: Data?
    func _jsonData(options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        return JSONSerialization._data(with: self, options: options)
    }
    
    /// Dictionary => JSON Data => [Hashable: T]
    /// - Parameter type: 要轉換成的Array類型
    /// - Returns: [T]?
    func _jsonClass<T: Decodable>(for type: [String: T].Type) -> [String: T] {
        
        var dictionary: [String: T] = [:]
        
        for (key, value) in self {
            guard let info = JSONSerialization._data(with: value)?._class(type: T.self) else { continue }
            dictionary["\(key)"] = info
        }
        
        return dictionary
    }
}

// MARK: - CLLocationCoordinate2D (Operator Overloading)
extension CLLocationCoordinate2D {
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        if (lhs.latitude != rhs.latitude) { return false }
        if (lhs.longitude != rhs.longitude) { return false }
        return true
    }
    
    static func +(lhs: Self, rhs: Self) -> Self {
        let coordinate = Self(latitude: lhs.latitude + rhs.latitude, longitude: lhs.longitude + rhs.longitude)
        return coordinate
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        let coordinate = Self(latitude: lhs.latitude - rhs.latitude, longitude: lhs.longitude - rhs.longitude)
        return coordinate
    }
}

// MARK: - JSONSerialization (static function)
extension JSONSerialization {
    
    /// [JSONObject => JSON Data](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-jsonserialization-印出美美縮排的-json-308c93b51643)
    /// - ["name":"William"] => {"name":"William"} => 7b226e616d65223a2257696c6c69616d227d
    /// - Parameters:
    ///   - object: Any
    ///   - options: JSONSerialization.WritingOptions
    /// - Returns: Data?
    static func _data(with object: Any, options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: options)
        else {
            return nil
        }
        
        return data
    }
}

// MARK: - FileManager (private class function)
extension FileManager {
    
    /// 讀取檔案文字
    /// - Parameters:
    ///   - url: 文件的URL
    ///   - encoding: 編碼格式
    /// - Returns: String?
    func _readText(from url: URL?, encoding: String.Encoding = .utf8) -> String? {
        
        guard let url = url,
              let readedText = try? String(contentsOf: url, encoding: encoding)
        else {
            return nil
        }
        
        return readedText
    }
}

// MARK: - UILabel (class function)
extension UILabel {
    
    /// 快建建立有文字的Label
    /// - Parameter text: String?
    /// - Returns: Self
    static func _text(_ text: String?) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }
}

// MARK: - UINavigationBarAppearance
extension UINavigationBarAppearance {
    
    /// 設定背景色透明 - UINavigationBar.appearance()._transparent()
    /// - Returns: UINavigationBarAppearance
    func _transparent() -> Self { configureWithTransparentBackground(); return self }
    
    /// 設定背景色
    /// - Parameter color: 顏色
    /// - Returns: UINavigationBarAppearance
    func _backgroundColor(_ color: UIColor?) -> Self { backgroundColor = color; return self }
    
    /// 設定背景圖片
    /// - Parameter image: UIImage?
    /// - Returns: UINavigationBarAppearance
    func _backgroundImage(_ image: UIImage?) -> Self { backgroundImage = image; return self }

    /// 設定下底線是否透明
    /// - Parameter hasShadow: 是否透明
    /// - Returns: UINavigationBarAppearance
    func _hasShadow(_ hasShadow: Bool = true) -> Self { if (!hasShadow) { shadowColor = nil }; return self }
    
    /// 設定預設的底色 (iOS13放大版的預設是透明)
    /// - Returns: UINavigationBarAppearance
    func _default() -> Self { configureWithDefaultBackground(); return self }
    
    /// 設定返回鍵圖示
    /// - Parameters:
    ///   - image: 顯示圖示
    ///   - maskImage: 遮罩的圖示
    /// - Returns: UINavigationBarAppearance
    func _backIndicatorImage(_ image: UIImage?, maskImage: UIImage?) -> Self { setBackIndicatorImage(image, transitionMaskImage: maskImage); return self }
}

// MARK: - UINavigationBar (class function)
extension UINavigationBar {
    
    /// [透明背景 (透明底線) => application(_:didFinishLaunchingWithOptions:)](https://sarunw.com/posts/uinavigationbar-changes-in-ios13/)
    func _transparent() { self.standardAppearance = UINavigationBarAppearance()._transparent() }
    
    /// 背景顏色 + 有沒有底線
    /// - 單一的UINavigationBar
    /// - Parameters:
    ///   - color: 背景顏色
    ///   - image: 底圖
    ///   - hasShadow: 有沒有底線
    func _backgroundColor(_ color: UIColor, image: UIImage = UIImage(), hasShadow: Bool = true) {
        self._backgroundColorForStandard(color, image: image, hasShadow: hasShadow)
        self._backgroundColorForScrollEdge(color, image: image, hasShadow: hasShadow)
    }
    
    /// 模糊（毛玻璃）效果
    /// - ∵ iOS13放大版的預設是透明 ∴ 可以變成小版的模糊效果
    func _blurEffect() { self.scrollEdgeAppearance = UINavigationBarAppearance()._default() }
    
    /// [背景顏色 + 背景圖片 + 有沒有底線 (滾動時的顏色 => standardAppearance) / iOS15預設是透明的](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/ios-15-navigation-bar-tab-bar-的樣式設定-558f07137b52)
    /// - Parameters:
    ///   - color: [背景顏色](https://stackoverflow.com/questions/69111478/ios-15-navigation-bar-transparent)
    ///   - image: 底圖
    ///   - hasShadow: 有沒有底線
    func _backgroundColorForStandard(_ color: UIColor, image: UIImage = UIImage(), hasShadow: Bool = true) {
        let settings = UINavigationBarAppearance()._backgroundColor(color)._backgroundImage(image)._hasShadow(hasShadow)
        self.standardAppearance = settings
    }
    
    /// [背景顏色 + 背景圖片 + 有沒有底線 (滾到低邊的顏色 => scrollEdgeAppearance)](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/ios-15-navigation-bar-tab-bar-的樣式設定-558f07137b52)
    /// - Parameters:
    ///   - color: [背景顏色](https://stackoverflow.com/questions/69111478/ios-15-navigation-bar-transparent)
    ///   - image: 底圖
    ///   - hasShadow: 有沒有底線
    func _backgroundColorForScrollEdge(_ color: UIColor, image: UIImage = UIImage(), hasShadow: Bool = true) {
        let settings = UINavigationBarAppearance()._backgroundColor(color)._backgroundImage(image)._hasShadow(hasShadow)
        self.scrollEdgeAppearance = settings
    }
}

// MARK: - MKMapView (class function)
extension MKMapView {
    
    /// [設定地圖樣式 => iOS 3.0 ~ iOS16.0](https://www.jianshu.com/p/cfa56060bc12)
    /// - Parameter type: [顯示地圖的樣式](https://developer.apple.com/documentation/mapkit/mkmapview/1452742-maptype)
    func _mapType(_ type: MKMapType = .standard) {
        self.mapType = type
    }
    
    /// [顯示自身定位位置](https://developer.apple.com/documentation/mapkit/mkmapview/1452682-showsuserlocation)
    /// - Parameter isShow: 是否顯示
    /// - Returns: Self
    func _showUserLocation(_ isShow: Bool = true) -> Self {
        self.showsUserLocation = isShow
        return self
    }
    
    /// [允許縮放地圖](https://developer.apple.com/documentation/mapkit/mkmapview/1452577-iszoomenabled)
    /// - Parameter isEnabled: Bool
    /// - Returns: Self
    func _zoomEnabled(_ isEnabled: Bool = true) -> Self {
        self.isZoomEnabled = isEnabled
        return self
    }
    
    /// [設定地圖中心點顯示範圍](https://medium.com/@albert1994/使用swift開發ios-app-mapkit-基本介紹-973e909f6497)
    /// - Parameters:
    ///   - latitude: [緯度 (南緯 / 北緯)](https://zh.wikipedia.org/zh-tw/全球定位系统)
    ///   - longitude: [經度 (東經 / 西經)](https://ithelp.ithome.com.tw/articles/10194371)
    ///   - scaleType: [可視的比例類型 - 距離 / 角度](https://developer.apple.com/documentation/corelocation/cllocationdistance)
    ///   - type: [地圖樣式](https://www.macotakara.jp/news/entry-43038.html)
    ///   - delegate: [MKMapViewDelegate](https://medium.com/彼得潘的-swift-ios-app-開發教室/熟練ios-sdk內建的delegate-三部曲-3069ea62f3d6)
    ///   - animated: [動畫開關](https://developer.apple.com/documentation/corelocation/cllocationdegrees)
    /// - Returns: Self
    func _regionCenter(latitude: CLLocationDegrees, longitude: CLLocationDegrees, scaleType: MapKitVisibleScaleType, type: MKMapType = .standard, delegate: MKMapViewDelegate?, animated: Bool = true) -> Self {
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region: MKCoordinateRegion
                
        switch scaleType {
        case .meters(let distance): region = MKCoordinateRegion(center: center, latitudinalMeters: distance, longitudinalMeters: distance)
        case .delta(let degrees): region = MKCoordinateRegion(center: center, span: .init(latitudeDelta: degrees, longitudeDelta: degrees))
        }
        
        self._mapType(type)
        self.delegate = delegate
        self.setRegion(region, animated: animated)
        
        return self
    }
    
    /// [建立基本型錨點](https://itisjoe.gitbooks.io/swiftgo/content/apps/taipeitravel/map.html)
    /// - Parameters:
    ///   - latitude: 緯度 (南緯 / 北緯)
    ///   - longitude: 經度 (東經 / 西經)
    ///   - title: 標題
    ///   - subtitle: 次標題
    /// - Returns: Self
    func _pin(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String?, subtitle: String?, overlayType: MapKitOverlayType? = nil) -> Self {
                
        if let overlayType = overlayType { self._overlay(latitude: latitude, longitude: longitude, type: overlayType) }

        let annotation = MKPointAnnotation._build(latitude: latitude, longitude: longitude, title: title, subtitle: subtitle)
        self.addAnnotation(annotation)
        
        return self
    }
    
    /// 註冊PinView (使用Class)
    /// - Parameter cellClass: 符合PinViewReusable的PinView
    func _registerPin<T: PinViewReusable>(with pinClass: T.Type) { register(T.self, forAnnotationViewWithReuseIdentifier: T.identifier) }
    
    /// 取得MKAnnotation
    /// - Parameter annotation: MKAnnotation
    /// - Returns: 符合CellReusable的Cell
    func _reusablePinView<T: PinViewReusable>(for annotation: MKAnnotation) -> T where T: MKAnnotationView {
        guard let pin = dequeueReusableAnnotationView(withIdentifier: T.identifier, for: annotation) as? T else { fatalError("MKAnnotation Error") }
        return pin
    }
    
    /// 新增遮罩
    /// - Parameters:
    ///   - latitude: 緯度 (南緯 / 北緯)
    ///   - longitude: 經度 (東經 / 西經)
    ///   - type: MapKitOverlayType
    /// - Returns: Self
    func _overlay(latitude: CLLocationDegrees, longitude: CLLocationDegrees, type: MapKitOverlayType) {
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let overlay: MKOverlay
        
        switch type {
        case .circle(let radius): overlay = MKCircle(center: coordinate, radius: radius)
        }
        
        self.addOverlay(overlay)
    }
    
    /// [設定地圖樣式 => 標準 / 航空寫真 + 標準 / 航空寫真](https://koogawa.hateblo.jp/entry/2022/06/10/095920)
    @available(iOS 16.0, *)
    func _mapConfiguration() { self.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .flat) }
}

// MARK: - MKPointAnnotation (static function)
extension MKPointAnnotation {
    
    /// 建立定位點
    /// - Parameters:
    ///   - latitude: 緯度 (南緯 / 北緯)
    ///   - longitude: 經度 (東經 / 西經)
    ///   - title: 標題
    ///   - subtitle: 次標題
    /// - Returns: MKPointAnnotation
    static func _build(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String?, subtitle: String?) -> MKPointAnnotation {
        let pin = MKPointAnnotation()._coordinate(latitude: latitude, longitude: longitude)._title(title)._subtitle(subtitle)
        return pin
    }
}

// MARK: - MKPointAnnotation (class function)
extension MKPointAnnotation {
    
    /// 設定坐標
    /// - Parameters:
    ///   - latitude: 緯度 (南緯 / 北緯)
    ///   - longitude: 經度 (東經 / 西經)
    /// - Returns: Self
    func _coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Self {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return self
    }
    
    /// 設定標題
    /// - Parameter title: String?
    /// - Returns: Self
    func _title(_ title: String?) -> Self {
        self.title = title
        return self
    }
    
    /// 設定次標題
    /// - Parameter subtitle: String?
    /// - Returns: Self
    func _subtitle(_ subtitle: String?) -> Self {
        self.subtitle = subtitle
        return self
    }
}

// MARK: - MKAnnotationView (class function)
extension MKAnnotationView {
    
    /// 新增遮罩
    /// - Parameters:
    ///   - mapView: MKMapView
    ///   - type: MapKitOverlayType
    /// - Returns: Bool
    func _overlay(on mapView: MKMapView, type: MapKitOverlayType) -> Bool {
        
        guard let coordinate = self.annotation?.coordinate else { return false }
        
        mapView._overlay(latitude: coordinate.latitude, longitude: coordinate.longitude, type: type)
        return true
    }
    
    /// [加上附件的顯示畫面](https://ithelp.ithome.com.tw/articles/10207873)
    /// - Parameters:
    ///   - leftView: UIView?
    ///   - rightView: UIView?
    ///   - detailView: UIView?
    ///   - canShow: 要不要顯示
    func _calloutAccessoryView(leftView: UIView?, rightView: UIView?, detailView: UIView?, canShow: Bool = true) {
        
        self.canShowCallout = canShow
        self.leftCalloutAccessoryView = leftView
        self.rightCalloutAccessoryView = rightView
        self.detailCalloutAccessoryView = detailView
    }
}

// MARK: - MKMarkerAnnotationView (class function)
extension MKMarkerAnnotationView {
    
    /// [設定顏色 / 圖示](https://medium.com/@kuotinyen/ios-11-mapkit-mkmarkerannotationview-api-簡介-b834a5364a4c)
    /// - Parameters:
    ///   - glyphTintColor: [大頭針圖示的顏色](https://medium.com/@jilljill860524/mapkit全解析-c17c344d3aca)
    ///   - markerTintColor: [大頭針背景色](https://swift.gg/2017/01/20/mapkit-beginner-guide/)
    ///   - type: [(未)點擊時文字 / 圖示](https://developer.apple.com/documentation/mapkit/mkpinannotationview)
    func _setting(pinColor glyphTintColor: UIColor?, backgroundColor markerTintColor: UIColor?, glyphType type: PinGlyphType) {
        
        self.glyphTintColor = glyphTintColor
        self.markerTintColor = markerTintColor
        
        switch type {
        case .text(let glyphText):
            self.glyphText = glyphText
        case .image(let glyphImage, let selectedGlyphImage):
            self.glyphImage = glyphImage
            self.selectedGlyphImage = selectedGlyphImage
        }
    }
}

// MARK: - MKCircleRenderer (static function)
extension MKCircleRenderer {
    
    /// 產生圓形距離範圍
    /// - Parameters:
    ///   - overlay: MKOverlay
    ///   - fillColor: UIColor?
    ///   - strokeColor: UIColor?
    ///   - lineWidth: CGFloat
    /// - Returns: MKCircleRenderer
    static func _build(for overlay: MKOverlay, fillColor: UIColor?, strokeColor: UIColor?, lineWidth: CGFloat = 1.0) -> MKCircleRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)._fillColor(fillColor)._strokeColor(strokeColor)._lineWidth(lineWidth)
        return renderer
    }
}

// MARK: - MKCircleRenderer (class function)
extension MKCircleRenderer {
    
    /// 圓形的底色
    /// - Parameter color: UIColor?
    /// - Returns: Self
    func _fillColor(_ color: UIColor?) -> Self { self.fillColor = color; return self }
    
    /// 圓形框線的顏色
    /// - Parameter color: UIColor?
    /// - Returns: Self
    func _strokeColor(_ color: UIColor?) -> Self { self.strokeColor = color; return self }
    
    /// 框線的粗細
    /// - Parameter width: CGFloat
    /// - Returns: Self
    func _lineWidth(_ width: CGFloat) -> Self { self.lineWidth = width; return self }
}

