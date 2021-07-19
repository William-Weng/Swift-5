//
//  ViewController.swift
//  UITableViewRowAction_Demo
//
//  Created by William.Weng on 2019/12/9.
//  Copyright © 2019 William.Weng. All rights reserved.
//
/// [Swift - 自定義tableViewCell滑動事件按鈕2（使用iOS11的滑動按鈕接口）](https://www.hangge.com/blog/cache/detail_1891.html)

import UIKit

// MARK: - Cell滑動按扭
final class ViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!

    private lazy var items: [String] = { return demoItemsMaker() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellMaker(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: leadingSwipeActionsMaker())
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: trailingSwipeActionsMaker())
    }
}

// MARK: - 畫面
extension ViewController {
    
    /// 左側滑動按鈕
    private func leadingSwipeActionsMaker() -> [UIContextualAction] {

        let unReadAction = contextualActionMaker(with: "未讀", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)) { print("未讀") }
        let readAction = contextualActionMaker(with: "已讀", color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)) { print("已讀") }
        
        return [unReadAction, readAction]
    }
    
    /// 右側滑動按鈕
    private func trailingSwipeActionsMaker() -> [UIContextualAction] {
        
        let moreAction = contextualActionMaker(color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), image: #imageLiteral(resourceName: "more")) { print("更多") }
        let deleteAction = contextualActionMaker(color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), image: #imageLiteral(resourceName: "delete")) { print("刪除") }

        return [moreAction, deleteAction]
    }
    
    /// Cell產生器
    private func cellMaker(for indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = items[indexPath.row]

        return cell
    }

    /// Cell滑動按鈕產生器 (文字 / 圖片)
    private func contextualActionMaker(with title: String? = nil, color: UIColor = .gray, image: UIImage? = nil, function: @escaping (() -> Void)) -> UIContextualAction {
        
        let contextualAction = UIContextualAction(style: .normal, title: title, handler:  { (action, view, headler) in
            function()
            headler(true)
        })
        
        contextualAction.backgroundColor = color
        contextualAction.image = image
        
        return contextualAction
    }
}

// MARK: - 主工具
extension ViewController {
    
    private func initSetting() {
        myTableView.delegate = self
        myTableView.dataSource = self
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 測試用資料
    private func demoItemsMaker() -> [String] {
        let items = ["項目1", "項目2", "項目3", "項目4", "項目5", "項目6", "項目7", "項目8", "項目9", "項目10", ]
        return items
    }
}
