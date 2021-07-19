//
//  ViewController.swift
//  PerpetualCalendar
//
//  Created by William.Weng on 2021/6/30.
//
/// [用UIPageViewController和UICollectionView實作萬年曆 - 陳仕偉 - Medium](https://areckkimo.medium.com/用uipageviewcontroller實作萬年曆-76edaac841e1)

import UIKit

// MARK: - 主要頁面的的Protocol
protocol MainViewControllerDelegate: AnyObject {
    
    /// 更新主頁面Title日期顯示
    /// - Parameters:
    ///   - currentDate: 當前日期 (第一次進APP的日期)
    ///   - offset: 月份增減的數量
    func updateTitle(currentDate: Date, offset: Int)
    
    /// 更新主頁面內容日期顯示
    /// - Parameters:
    ///   - currentDate: 當前日期 (第一次進APP的日期)
    ///   - offset: 月份增減的數量
    func updateCalendar(currentDate: Date, offset: Int)
}

// MARK: - 主要頁面的的UIViewController
final class MainViewController: UIViewController {

    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    private var perpetualPageViewController: PerpetualPageViewController?

    lazy var titleLabel: UILabel? = { return UILabel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { initSetting(for: segue, sender: sender) }
    
    /// 上一頁月曆
    @IBAction func previousPage(_ sender: UIBarButtonItem) {
        perpetualPageViewController?.previousPage()
    }
    
    /// 下一頁月曆
    @IBAction func nextPage(_ sender: UIBarButtonItem) {
        perpetualPageViewController?.nextPage()
    }
    
    /// 更新成這個月
    @IBAction func refreshCalendar(_ sender: UIBarButtonItem) {
        updateCalendar(currentDate: CalendarCollectionViewCell.CurrentDate, offset: 0)
    }
    
    /// 選擇日期Picker
    /// - Parameter recognizer: UITapGestureRecognizer
    @objc func dataPickerSelected(_ recognizer: UITapGestureRecognizer?) {
        
        guard let viewController = UIStoryboard._instantiateViewController(name: "Main", bundle: nil, identifier: "DatePickerViewController") as? DatePickerViewController else { return }
        
        viewController._transparent(.black.withAlphaComponent(0.3))
        viewController.myDelegte = self
        
        present(viewController, animated: true) {
            wwPrint("DatePickerViewController")
        }
    }
}

// MARK: - 自定義的Delegate
extension MainViewController: MainViewControllerDelegate {
    
    func updateTitle(currentDate: Date, offset: Int) {
        titleLabel?.text = currentDate._adding(component: .month, value: offset)?._localTime(with: .yearMonth, timeZone: .Asia_Taipei)
        titleLabel?.sizeToFit()
        CalendarCollectionViewCell.MonthOffset = offset
    }
    
    func updateCalendar(currentDate: Date, offset: Int) {
        
        guard let viewController = perpetualPageViewController?.viewControllers?.first as? CalendarViewController else { return }
        
        updateTitle(currentDate: currentDate, offset: offset)
        viewController.reloadPage(with: offset)
        perpetualPageViewController?.nextPage(false)
        perpetualPageViewController?.previousPage(false)
    }
}

// MARK: - 小工具
extension MainViewController {
    
    /// 初始化 PerpetualPageViewController
    /// - Parameters:
    ///   - segue: UIStoryboardSegue
    ///   - sender: Any?
    private func initSetting(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let pageViewController = segue.destination as? PerpetualPageViewController else { return }
        
        pageViewController.myDelegte = self
        self.perpetualPageViewController = pageViewController
    }
    
    /// 初始化設定
    private func initSetting() {
        titleLabelSetting()
        updateTitle(currentDate: CalendarCollectionViewCell.CurrentDate, offset: CalendarCollectionViewCell.MonthOffset)
    }
    
    /// Title的文字框設定
    private func titleLabelSetting() {
        
        let tapGestureRecognizer = UITapGestureRecognizer._build(target: self, action: #selector(dataPickerSelected(_:)))

        titleLabel?.isUserInteractionEnabled = true
        titleLabel?.addGestureRecognizer(tapGestureRecognizer)
        
        myNavigationItem.titleView = titleLabel
    }
}
