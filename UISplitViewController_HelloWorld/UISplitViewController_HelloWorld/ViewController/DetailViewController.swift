//
//  DetailViewController.swift
//  UISplitViewController_HelloWorld
//
//  Created by William.Weng on 2020/9/29.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit
import WebKit
import PDFKit
import AVKit
import JGProgressHUD
import Toast

// MARK: - 主頁內容
final class DetailViewController: UIViewController, WKUIDelegate {
        
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfThumbnailView: PDFThumbnailView!
    @IBOutlet weak var pdfScrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pdfScrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var airPlayButtonItem: UIBarButtonItem!
    
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    private let thumbnailSize = CGSize(width: 128, height: 128)
    private let loadindHUD = JGProgressHUD()

    private var preferredDisplayMode: UISplitViewController.DisplayMode = .primaryOverlay
    private var pageCount: Int?
    private var isThumbnailViewHidden = false
    private var isNavigationBarHidden = false
    
    override func viewDidLoad() { super.viewDidLoad(); initSetting() }
}

// MARK: - @IBAction
extension DetailViewController {
        
    /// 分享
    @IBAction func shared(_ sender: UIBarButtonItem) {
        
        let title = MyCell.PDFInfomations[safe: indexPath.row]?.title ?? "NONE"
        let activityItems = [title]
        let activityViewController = UIActivityViewController._maker(activityItems: activityItems, applicationActivities: nil, tintColor: .white, anchorItem: sender)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    /// AirPrint (UIPrintInteractionController)
    @IBAction func airPrint(_ sender: UIBarButtonItem) {
        
        guard let urlString = MyCell.PDFInfomations[safe: indexPath.row]?.url,
              let url = URL(string: urlString),
              let printingData = try? Data(contentsOf: url),
              let result = Optional.some(UIPrintInteractionController._result(printingData: printingData, jobName: "DEMO"))
        else {
            return
        }

        switch result {
        case .failure(let error): wwPrint(error)
        case .success(let printInteractionController): printInteractionController.present(animated: true, completionHandler: nil)
        }
    }
}

// MARK: - @objc
extension DetailViewController {

    /// 顯示選單
    @objc func showMenu(_ sender: UIBarButtonItem) { splitViewPreferredDisplayModeSetting(.primaryOverlay) }
    
    /// 滑動換頁
    /// - 左滑 => 上一頁 / 右滑 => 下一頁
    @objc func swipeGestureWithNextPage(_ recognizer: UISwipeGestureRecognizer) {
        
        let direction = recognizer.direction
        
        switch direction {
        case .left:
            
            guard pdfView.canGoToNextPage else { return }
            pdfView.goToNextPage(nil)
            snapshotAnimation(with: pdfView, direction: .left)
            
        case .right:
            
            guard pdfView.canGoToPreviousPage else { return }
            
            pdfView.goToPreviousPage(nil)
            snapshotAnimation(with: pdfView, direction: .right)
            
        default: break
        }
    }
    
    /// 顯示 / 隱藏View
    /// - 上 => 隱藏NavigationBar -> 顯示ThumbnailView / 下 => 顯示NavigationBar -> 隱藏ThumbnailView
    @objc func swipeGestureWithHidden(_ recognizer: UISwipeGestureRecognizer) {
        
        let direction = recognizer.direction
        
        switch direction {
        case .up:
            if isThumbnailViewHidden { thumbnailViewHidden(false); return }
            navigationBarHidden(true)
        case .down:
            if !isThumbnailViewHidden { thumbnailViewHidden(true); return }
            navigationBarHidden(false)
        default: break
        }
    }
    
    /// 換頁時後動作
    /// - Notification => NSNotification.Name.PDFViewPageChanged
    @objc func pdfViewPageChanged(_ notification: Notification) {
        
        guard let pageCount = pageCount,
              let currentPage = pdfView.currentPage,
              let pageNumber = currentPage.pageRef?.pageNumber,
              let pageCountDescription = Optional.some("\(pageNumber._repeatString(count: UInt(pageCount.description.count))) of \(pageCount)")
        else {
            return
        }
        
        showToastTitle(pageCountDescription, on: view)
    }
}

// MARK: - PDFViewDelegate
extension DetailViewController: PDFViewDelegate {
    
    func pdfViewPerformFind(_ sender: PDFView) {}
    func pdfViewPerformGo(toPage sender: PDFView) {}
    func pdfViewOpenPDF(_ sender: PDFView, forRemoteGoToAction action: PDFActionRemoteGoTo) {}
    
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        UIApplication.shared.open(url, options: [:]) { (isSuccess) in }
    }
}

// MARK: - 小工具
extension DetailViewController {
    
    /// 初始化設定
    private func initSetting() {
        
        splitViewPreferredDisplayModeSetting()
        leftBarButtonItemSetting()
        
        pdfThumbnailViewSetting(with: pdfView, size: thumbnailSize)
        pdfViewSetting()
        loadPDFDocument(with: indexPath)
        
        airPlayButtonItem.customView = AVRoutePickerView._customView()
        
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "background"), for: .default)
    }
    
    /// PDFView相關設定
    /// - delegate / notification / 顏色…
    private func pdfViewSetting() {
        
        pdfView.delegate = self
        pdfView.usePageViewController(true, withViewOptions: nil)
        
        usePDFPageViewController(enable: false)
                
        NotificationCenter.default.addObserver(self, selector: #selector(pdfViewPageChanged(_:)), name: .PDFViewPageChanged, object: nil)
    }
    
    /// 讀取PDFView文件 + 縮圖
    /// - delay是為了不讓UI更新被卡住 (主執行緒)
    private func loadPDFDocument(with indexPath: IndexPath, displayMode: PDFDisplayMode = .singlePage) {
        
        guard let pdfInfomation = MyCell.PDFInfomations[safe: indexPath.row],
              let urlString = Optional.some(pdfInfomation.url),
              let pdfURL = URL(string: urlString),
              let splitView = splitViewController?.view
        else {
            return
        }
        
        title = pdfInfomation.title
        loadingStatus(isEnable: true, in: splitView)
        
        _ = self.pdfView._displayMode(displayMode)._backgroundColor(.black)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.pdfView._document(url: pdfURL) { result in
                
                self.loadingStatus(isEnable: false, in: splitView)
                
                switch result {
                case .failure(let error): wwPrint(error)
                case .success(let pageCount):
                    
                    self.pageCount = pageCount
                    self.pdfThumbnailViewSize(pageCount: pageCount, size: self.thumbnailSize)
                    
                    Notification._post(name: .PDFViewPageChanged)
                }
            }
        }
    }
    
    /// 設定PDF縮圖頁的大小
    /// - 直接動態更新
    /// - 因為有單頁畫面的問題 => 太短
    private func pdfThumbnailViewSize(pageCount: Int, size: CGSize) {
        
        let screenWidth = UIScreen.main.bounds.width
        let scrollViewContentWidth = CGFloat(pageCount) * size.width
        let newWidth = (scrollViewContentWidth > screenWidth) ? scrollViewContentWidth : screenWidth
        
        pdfScrollViewWidthConstraint.constant = newWidth
        view.layoutIfNeeded()
    }
    
    /// PDF縮圖頁的設定
    private func pdfThumbnailViewSetting(with pdfView: PDFView, size: CGSize) {
        
        pdfThumbnailView.pdfView = pdfView
        pdfThumbnailView.thumbnailSize = size
        pdfThumbnailView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1961419092)
        pdfThumbnailView.layoutMode = .horizontal
    }
    
    /// 設定PDFView的手勢動作
    private func pdfViewGestureRecognizerSetting() {
        
        let upSwipe = UISwipeGestureRecognizer._maker(target: self, direction: .up, action: #selector(swipeGestureWithHidden(_:)))
        let downSwipe = UISwipeGestureRecognizer._maker(target: self, direction: .down, action: #selector(swipeGestureWithHidden(_:)))
        let leftSwipe = UISwipeGestureRecognizer._maker(target: self, direction: .left, action: #selector(swipeGestureWithNextPage(_:)))
        let rightSwipe = UISwipeGestureRecognizer._maker(target: self, direction: .right, action: #selector(swipeGestureWithNextPage(_:)))

        pdfView._addGestureRecognizers(with: [upSwipe, downSwipe, leftSwipe, rightSwipe])
    }
    
    /// 是否使用PDFKit自訂的滑動手勢 or 自定義的手勢
    private func usePDFPageViewController(enable: Bool = false) {
        pdfView.usePageViewController(enable, withViewOptions: nil)
        if (!enable) { pdfViewGestureRecognizerSetting() }
    }
    
    /// 選單的切換模式設定 (動畫)
    private func splitViewPreferredDisplayModeSetting(_ mode: UISplitViewController.DisplayMode = .primaryOverlay) {
        guard let splitViewController = splitViewController else { return }
        UIView.animate(withDuration: 0.3) { splitViewController.preferredDisplayMode = mode }
    }
    
    /// 設定左側選單按鈕 (自訂)
    private func leftBarButtonItemSetting() {
        navigationItem.leftItemsSupplementBackButton = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(showMenu(_:)))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    /// 轉圈圈的狀態 (Loading)
    /// - Loading => 選單 + 縮圖 隱藏
    /// - Loaded => 縮圖 顯示
    private func loadingStatus(isEnable: Bool, in view: UIView) {
        
        if (isEnable) {
            loadindHUD.show(in: view, animated: true)
            splitViewPreferredDisplayModeSetting(.primaryHidden)
            pdfThumbnailView.alpha = 0.0; return
        }

        self.loadindHUD.dismiss(afterDelay: 0.5)
        pdfThumbnailView.alpha = 1.0
    }

    /// 顯示 / 隱藏NavigationBar + StateBar
    private func navigationBarHidden(_ isHidden: Bool) {
        
        guard let baseViewController = splitViewController as? StatusBarHideable,
              let navigationController = navigationController
        else {
            return
        }
        
        baseViewController.isStatusBarHidden = isHidden
        navigationController._navigationBarHidden(isHidden)
        isNavigationBarHidden = isHidden
    }
    
    /// 顯示 / 隱藏縮圖
    private func thumbnailViewHidden(_ isHidden: Bool) {
        
        pdfScrollViewHeightConstraint.constant = (isHidden) ? .zero : thumbnailSize.height
        isThumbnailViewHidden = isHidden
                
        UIView.animate(withDuration: 0.2) { self.view.layoutIfNeeded() }
    }
    
    /// 顯示頁數的提示視窗
    private func showToastTitle(_ title: String, on view: UIView, messageColor: UIColor = .black, backgroundColor: UIColor = .lightGray, duration: TimeInterval = 0.5) {
        
        var toastStyle = ToastStyle()
        toastStyle.messageColor = messageColor
        toastStyle.backgroundColor = backgroundColor
        
        view.makeToast(title, duration: duration, position: .bottom, style: toastStyle)
    }
    
    /// 換頁動畫
    /// - 利用SnapshotView
    private func snapshotAnimation(with view: UIView, direction: UISwipeGestureRecognizer.Direction) {
        
        guard let snapshotView = view.snapshotView(afterScreenUpdates: false) else { return }
        
        var animationWidth: CGFloat = 0
        
        switch direction {
        case .left: animationWidth = -UIScreen._mainBounds().width
        case .right: animationWidth = UIScreen._mainBounds().width
        default: animationWidth = 0
        }
        
        view.addSubview(snapshotView)

        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModePaced, animations: {
            snapshotView.frame = CGRect(origin: CGPoint(x: animationWidth, y: 0), size: view.frame.size)
            snapshotView.alpha = 0.0
        }, completion: { _ in
            snapshotView.removeFromSuperview()
        })
    }
}

