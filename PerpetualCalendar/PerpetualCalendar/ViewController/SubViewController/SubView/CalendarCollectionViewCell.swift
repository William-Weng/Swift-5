//
//  MyCollectionViewCell.swift
//  PerpetualCalendar
//
//  Created by William.Weng on 2021/7/1.
//

import UIKit

// MARK: - 單日顯示的Cell
final class CalendarCollectionViewCell: UICollectionViewCell, CellReusable {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    static let CurrentDate: Date = Date()
    
    static var CalendarDates: [Date] = []
    static var MonthOffset = 0
    
    func configure(with indexPath: IndexPath) { self.dateLabelSetting(with: indexPath) }
}

// MARK: - 小工具
extension CalendarCollectionViewCell {
    
    /// 顯示日期文字的相關設定
    /// - Parameter indexPath: IndexPath
    private func dateLabelSetting(with indexPath: IndexPath) {

        let calendarDate = Self.CalendarDates[safe: indexPath.row]

        self.dateLabel.text = calendarDate?._localTime(with: .day, timeZone: .Asia_Taipei)
        self.dateLabelTextColorSetting(indexPath: indexPath, calendarDate: calendarDate)
    }
    
    /// 日期文字的顏色設定
    /// - Parameters:
    ///   - indexPath: IndexPath
    ///   - calendarDate: 該日的時間
    ///   - enableColor: 是當月日期的文字顏色
    ///   - disableColor: 非當月日期的文字顏色
    private func dateLabelTextColorSetting(indexPath: IndexPath, calendarDate: Date?, enableColor: UIColor = .black, disable disableColor: UIColor = .lightGray) {
        
        let calendarCurrentDate = Self.CurrentDate._adding(component: .month, value: Self.MonthOffset)
        let isEqual = calendarCurrentDate?._compare(equal: calendarDate, with: .yearMonth)

        self.dateLabel.textColor = (isEqual ?? false) ? enableColor : disableColor
    }
}

