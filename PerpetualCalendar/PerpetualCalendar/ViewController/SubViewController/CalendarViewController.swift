//
//  CalendarViewController.swift
//  PerpetualCalendar
//
//  Created by William.Weng on 2021/6/30.
//

import UIKit

// MARK: - 月曆本體
final class CalendarViewController: UIViewController {

    @IBOutlet weak var myCollectionView: UICollectionView!
        
    private let calendarCount: (days: Int, weeks: Int) = (7, 6)     /* (一週7天, 顯示6週) */
    
    var monthOffset = 0                                             /* (月的偏移量 => 下一個月？) */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return CalendarCollectionViewCell.CalendarDates.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView._reusableCell(at: indexPath) as CalendarCollectionViewCell
        cell.configure(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / calendarCount.days._CGFloat()
        let height = collectionView.frame.height / calendarCount.weeks._CGFloat()
        
        return CGSize(width: floor(width), height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { return .zero }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return .zero }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return .zero }
}

// MARK: - 小工具
extension CalendarViewController {
    
    /// 重新更新月曆資訊
    /// - Parameter monthOffset: -1 <- 當月 -> +1
    func reloadPage(with monthOffset: Int) {
        
        guard let calendarDates = calendarDatesMaker(monthOffset: monthOffset, days: calendarCount.days, weeks: calendarCount.weeks) else { return }
        
        CalendarCollectionViewCell.CalendarDates = calendarDates
        myCollectionView.reloadData()
    }
    
    /// 設定初始值
    private func initSetting() {

        myCollectionView._delegateAndDataSource(with: self)

        CalendarCollectionViewCell.CalendarDates = calendarDatesMaker(monthOffset: CalendarCollectionViewCell.MonthOffset, days: calendarCount.days, weeks: calendarCount.weeks)!
    }
    
    /// 月曆數值產生器
    /// - Parameters:
    ///   - date: 當月的某一天
    ///   - monthOffset: -1 <- 當月 -> +1
    ///   - days: 一週有幾天
    ///   - weeks: 要顯示幾週
    /// - Returns: [Date]?
    private func calendarDatesMaker(monthOffset: Int = 0, days: Int = 7, weeks: Int = 6) -> [Date]? {
        
        guard let selectedDayOfMonth = CalendarCollectionViewCell.CurrentDate._adding(component: .month, value: monthOffset),
              let firstDayOfMonth = selectedDayOfMonth._firstDayOfMonth(),
              let firstDayWeek = Optional.some(firstDayOfMonth._weekday())
        else {
            return nil
        }
        
        var calendarDates: [Date] = []
        
        for index in 0..<(days * weeks) {
            let offsetDays = index - firstDayWeek + 1
            if let date = firstDayOfMonth._adding(value: offsetDays) { calendarDates.append(date) }
        }
        
        return calendarDates
    }
}
