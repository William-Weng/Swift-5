//
//  PerpetualPageViewController.swift
//  PerpetualCalendar
//
//  Created by William.Weng on 2021/7/1.
//

import UIKit

// MARK: - 萬年曆的UIPageViewController
final class PerpetualPageViewController: UIPageViewController {
        
    weak var myDelegte: MainViewControllerDelegate?     /* (月的偏移量 => 下一個月？) */
            
    override func viewDidLoad() {
        super.viewDidLoad()
        initSettig()
    }
}

// MARK: - 公開給其它人用的工具
extension PerpetualPageViewController {

    /// [上一頁 => 換頁 (setViewControllers(_:animated:) => 執行UIPageViewControllerDataSource)](https://developer.apple.com/documentation/uikit/uinavigationcontroller/1621861-setviewcontrollers)
    func previousPage(_ animated: Bool = true) {
        
        guard let previousViewController = directionViewControllerMaker(self, direction: .reverse) else { return }
        self.setViewControllers([previousViewController], direction: .reverse, animated: animated) { _ in self.updateNavigationTitle() }
    }

    /// 下一頁 => 換頁 (setViewControllers(_:animated:) => 執行UIPageViewControllerDataSource)
    func nextPage(_ animated: Bool = true) {
        
        guard let nextViewController = directionViewControllerMaker(self, direction: .forward) else { return }
        self.setViewControllers([nextViewController], direction: .forward, animated: animated) { _ in self.updateNavigationTitle() }
    }
}

// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension PerpetualPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let previousViewController = newCalendarViewController(with: CalendarCollectionViewCell.MonthOffset - 1)
        return previousViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let nextViewController = newCalendarViewController(with: CalendarCollectionViewCell.MonthOffset + 1)
        return nextViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {}
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (finished) {
            
            guard let calendarViewController = viewControllers?.first as? CalendarViewController else { return }
            
            CalendarCollectionViewCell.MonthOffset = calendarViewController.monthOffset
            self.updateNavigationTitle()
                        
            DispatchQueue.main.async { calendarViewController.reloadPage(with: CalendarCollectionViewCell.MonthOffset) }
        }
    }
    
    /// 更新NavigationTitle
    private func updateNavigationTitle() {
        myDelegte?.updateTitle(currentDate: CalendarCollectionViewCell.CurrentDate, offset: CalendarCollectionViewCell.MonthOffset)
    }
}

// MARK: - 小工具
extension PerpetualPageViewController {
    
    /// 初始化設定
    private func initSettig() {
        self._delegateAndDataSource(with: self)
        self.setViewControllers([newCalendarViewController(with: CalendarCollectionViewCell.MonthOffset)], direction: .forward, animated: true) { _ in }
    }
    
    /// 產生新的下一頁
    /// - Returns: CalendarViewController
    private func newCalendarViewController(with offset: Int = 0) -> CalendarViewController {
        
        let calendarViewController = UIStoryboard._instantiateViewController() as CalendarViewController
        calendarViewController.monthOffset = offset
        
        return calendarViewController
    }
    
    /// 上 / 下一頁的ViewController
    /// - Parameters:
    ///   - pageViewController: UIPageViewController
    ///   - direction: 上一頁 (before) / 下一頁 (after)
    /// - Returns: CalendarViewController?
    private func directionViewControllerMaker(_ pageViewController: UIPageViewController, direction: UIPageViewController.NavigationDirection) -> CalendarViewController? {
        
        guard let currentViewController = pageViewController.viewControllers?.first else { return nil }
        
        var directionViewController: CalendarViewController?
        
        switch direction {
        case .forward:
            directionViewController = pageViewController.dataSource?.pageViewController(pageViewController, viewControllerBefore: currentViewController) as? CalendarViewController
            CalendarCollectionViewCell.MonthOffset += 1
        case .reverse:
            directionViewController = pageViewController.dataSource?.pageViewController(pageViewController, viewControllerBefore: currentViewController) as? CalendarViewController
            CalendarCollectionViewCell.MonthOffset -= 1
        @unknown default: break
        }
        
        return directionViewController
    }
}
