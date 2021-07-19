//
//  MasterViewController.swift
//  UISplitViewController_HelloWorld
//
//  Created by William.Weng on 2020/9/29.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

// MARK: - 側邊選單
final class MasterViewController: UITableViewController {
    
    private var scrollViewTopHeight: CGFloat = 384

    private lazy var headerView: UIImageView = initHeaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); reloadSelectedCell() }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { deatailSetting(for: segue) }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MasterViewController {

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return MyCell.PDFInfomations.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return tableViewCell(tableView, cellForRowAt: indexPath) }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) { headerViewSetting(with: scrollView) }
}

// MARK: - 小工具
extension MasterViewController {
    
    /// 初始化設定
    private func initSetting() {
        
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: scrollViewTopHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
        
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "background"), for: .default)
    }
    
    /// 初始化HeaderView
    private func initHeaderView() -> UIImageView {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let width = splitViewController?.minimumPrimaryColumnWidth ?? 512
        let icon = MyCell.PDFInfomations[safe: indexPath.row]?.icon
        
        return headerView(width: width, height: scrollViewTopHeight, image: icon)
    }
    
    /// 當捲動的高度超過384時，就開始更動header的frame
    private func headerViewSetting(with scrollView: UIScrollView) {
        headerView.frame = scrollView._navigationItemHeaderViewZoomFrame(navigationController, headerView: headerView, isUnderBarView: false)
    }
    
    /// 內容頁的設定
    private func deatailSetting(for segue: UIStoryboardSegue) {
        
        guard let indexPath = tableView.indexPathForSelectedRow,
              let navigationController = segue.destination as? UINavigationController,
              let detailViewController = navigationController.topViewController as? DetailViewController
        else {
            return
        }
        
        changeHeaderViewInfomation(with: indexPath)
        
        detailViewController.indexPath = indexPath
        detailViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
    }
    
    /// 改變HeaderView的圖示
    private func changeHeaderViewInfomation(with indexPath: IndexPath) {
        headerView.image = MyCell.PDFInfomations[safe: indexPath.row]?.icon
    }
    
    /// 記得上一次點到哪一個，重load => 滾到最上面
    private func reloadSelectedCell() {
        guard let splitViewController = splitViewController else { return }
        clearsSelectionOnViewWillAppear = splitViewController.isCollapsed
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    /// 產生 / 設定 Cell
    private func tableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView._reusableCell(at: indexPath) as MyCell
        cell.configure(with: indexPath)

        return cell
    }
    
    /// 產生要放大縮小的HeaderView (高度自動會由CollectionView決定)
    private func headerView(width: CGFloat = UIScreen.main.bounds.size.width, height: CGFloat, image: UIImage?) -> UIImageView {
        
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: -height), size: CGSize(width: width, height: height)))
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
}
