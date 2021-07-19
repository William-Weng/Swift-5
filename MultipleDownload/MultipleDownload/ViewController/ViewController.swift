//
//  ViewController.swift
//  MultipleDownload
//
//  Created by William.Weng on 2020/8/24.
//  Copyright © 2020 William.Weng. All rights reserved.
//
/// [GCD和Operation/OperationQueue 看這一篇文章就夠了](https://medium.com/@crafttang/gcd和operation-operationqueue-看这一篇文章就够了-f38d50521543)
/// [GCD 多執行緒的說明與應用](https://medium.com/@mikru168/ios-gcd多執行緒的說明與應用-c69a68d01da1)
/// [iOS複習筆記之 runLoop詳解](https://shenfh.github.io/2016/09/21/review1/)
/// [GCD進階之DispatchWorkItem和DispatchGroup](https://www.jianshu.com/p/65c333777571)
/// [URLSession詳解](https://www.jianshu.com/p/4e69bc24795d)
/// [iOS 並行程式設計: 初探 NSOperation 和 Dispatch Queues](https://www.appcoda.com.tw/ios-concurrency/)
/// [NSURLSession實現多任務斷點下載 - LCDownloadManager](https://www.jianshu.com/p/534ec0d9d758)

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet var myImageViewArray: [UIImageView]!
    @IBOutlet var myProgressViewArray: [UIProgressView]!
    
    private let imageUrlInfoArray: [String] = [
        ("http://www.theenergytrail.com/wp-content/uploads/2017/03/st.-patricks-day.jpeg"),
        ("http://www.theenergytrail.com/wp-content/uploads/2017/03/restaurant-kitchen.jpg"),
        ("http://www.theenergytrail.com/wp-content/uploads/2017/03/jason-blackeye-139308.jpg"),
        ("http://www.theenergytrail.com/wp-content/uploads/2017/03/tax-credits-1.jpeg"),
        ("http://www.theenergytrail.com/wp-content/uploads/2017/03/marchmadness2.jpg"),
    ]

    private let DownloadFinishName = Utility.shared.notificationNameMaker("DownloadFinish")
    private let ProgressName = Utility.shared.notificationNameMaker("Progress")

    private var downloadTaskIdentifierArray: [String] = []
    private var downloadImageProgressDictionary: [String: Float] = [:]
    private var downloadImageDataDictionary: [String: Data] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        registeredNotification()
    }

    @IBAction func downloadImages(_ sender: UIBarButtonItem) { multipleDownloadImages(with: imageUrlInfoArray) }
    
    deinit { wwPrint("deinit") }
}

// MARK: - 主工具
extension ViewController {
    
    /// 多任務下載圖片
    private func multipleDownloadImages(with imageUrlStringArray: [String]) {
        
        downloadTaskIdentifierArray = []
        myImageViewArray.forEach { $0.image = nil }
        myProgressViewArray.forEach { $0.progress = 0 }
        
        let downloadTasks = UtilityWeb.shared.multipleDownloadFileTaskMaker(with: imageUrlStringArray, downloadBytes: { (byteInfo) in
                        
            let progress = Float(byteInfo.written) / Float(byteInfo.total)
            self.downloadImageProgressDictionary[byteInfo.taskIdentifier] = progress
            Utility.shared.postNotification(name: self.ProgressName)
            
        }, finish: { (result) in
                        
            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let _info):
                self.downloadImageDataDictionary[_info.taskIdentifier] = _info.data
                Utility.shared.postNotification(name: self.DownloadFinishName)
            }
        })
        
        downloadTasks.forEach { (task) in
            downloadTaskIdentifierArray.append("\(task)")
            task.resume()
        }
    }
}

// MARK: - 小工具
extension ViewController {

    /// 註冊Notification (利用task的id當key)
    private func registeredNotification() {
        Utility.shared.registeredNotification(name: ProgressName) { (_) in self.updateProgressViews() }
        Utility.shared.registeredNotification(name: DownloadFinishName) { (_) in self.updateImageViews() }
    }
    
    /// 更新進度條
    private func updateProgressViews() {
        for index in 0..<downloadTaskIdentifierArray.count {
            let identifier = downloadTaskIdentifierArray[index]
            if let progress = downloadImageProgressDictionary[identifier] { myProgressViewArray[index].progress = progress }
        }
    }

    /// 更新UIImageView
    private func updateImageViews() {
        for index in 0..<downloadTaskIdentifierArray.count {
            let identifier = downloadTaskIdentifierArray[index]
            if let data = downloadImageDataDictionary[identifier] { myImageViewArray[index].image = UIImage(data: data) }
        }
    }
}
