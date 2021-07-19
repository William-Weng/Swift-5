//
//  iPhoneSizeInfomation.swift
//  WallpaperOfGrid
//
//  Created by William.Weng on 2019/8/21.
//  Copyright © 2019 William.Weng. All rights reserved.
//

import UIKit

typealias BarDistance = (top: CGFloat, bottom: CGFloat)
typealias iPhoneDesktopInfo = (iconSize: CGSize, gapSize: CGSize, barDistance: BarDistance)
typealias iPhoneIconRangeInfo = (firstColumn: ClosedRange<Int>, lastColumn: ClosedRange<Int>)
typealias ColorInfo = (title: String, color: UIColor)

enum RowType: Int {
    case first = 0
    case second = 1
    case third = 2
    case last = 3
}

enum iPhoneSizeInfomation {
    
    case _35inch
    case _40inch
    case _47inch
    case _55inch
    case _58inch
    case _61inch
    case _65inch
    
    static var type: iPhoneSizeInfomation? { return getType() }
    static var bounds: ScreenBoundsInfo { return getBounds() }
    static var iconMaxCount: Int { return pageCountInfos()[type ?? _35inch] ?? 0 }
    
    /// Screen的資訊
    struct ScreenBoundsInfo: Equatable {
        var width: CGFloat
        var height: CGFloat
        var scale: CGFloat
    }
    
    /// 取得iPhone的Screen的大小Type
    private static func getType() -> iPhoneSizeInfomation? {
        
        let boundsInfo = ScreenBoundsInfo(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, scale: UIScreen.main.scale)
        let screenBoundsInfos = mainScreenBoundsInfos()
        
        for _screenBoundsInfo in screenBoundsInfos {
            if (_screenBoundsInfo.value == boundsInfo) { return _screenBoundsInfo.key }
        }
        
        return nil
    }
    
    /// 取得iPhone的Screen的大小
    private static func getBounds() -> ScreenBoundsInfo {
        return ScreenBoundsInfo(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, scale: UIScreen.main.scale)
    }
    
    /// 取得記錄iPhone的大小跟比例的Array (https://www.idev101.com/code/User_Interface/sizes.html)
    private static func mainScreenBoundsInfos() -> [iPhoneSizeInfomation: ScreenBoundsInfo] {
        
        let screenBoundsInfos: [iPhoneSizeInfomation: ScreenBoundsInfo] = [
            ._35inch: ScreenBoundsInfo(width: 320, height: 480, scale: 2),
            ._40inch: ScreenBoundsInfo(width: 320, height: 568, scale: 2),
            ._47inch: ScreenBoundsInfo(width: 375, height: 667, scale: 2),
            ._55inch: ScreenBoundsInfo(width: 414, height: 736, scale: 3),
            ._58inch: ScreenBoundsInfo(width: 375, height: 812, scale: 3),
            ._61inch: ScreenBoundsInfo(width: 375, height: 812, scale: 2),
            ._65inch: ScreenBoundsInfo(width: 414, height: 896, scale: 3),
        ]
        
        return screenBoundsInfos
    }
    
    /// 取得記錄iPhone的單頁icon最大數量Array
    private static func pageCountInfos() -> [iPhoneSizeInfomation: Int] {
        
        let countInfos: [iPhoneSizeInfomation: Int] = [
            ._35inch: 24,
            ._40inch: 24,
            ._47inch: 28,
            ._55inch: 28,
            ._58inch: 28,
            ._61inch: 28,
            ._65inch: 28,
        ]
        
        return countInfos
    }
}
