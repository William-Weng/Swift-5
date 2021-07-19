//
//  DownloadViewController.swift
//  MultipleDownload
//
//  Created by William.Weng on 2020/8/25.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

final class DownloadViewController: UIViewController {

    @IBOutlet var myImageViewArray: [UIImageView]!
    @IBOutlet var myLabelArray: [UILabel]!
    @IBOutlet var indicatorViewArray: [UIActivityIndicatorView]!
    
    private let imageUrlString = "http://www.theenergytrail.com/wp-content/uploads/2017/03/tax-credits-1.jpeg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func downloadImage(_ sender: UIBarButtonItem) {
        
        let startTime = Date()
        indicatorViewArray.first?.startAnimating()
        myImageViewArray.first?.image = nil
        myLabelArray.first?.text = "單點下載"

        let task = UtilityWeb.shared.downloadRequestTask(urlString: imageUrlString, downloadBytes: { (bytesInfo) in
            wwPrint(bytesInfo)
        }, finish: { (result) in
            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let info):

                let time = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                
                self.indicatorViewArray.first?.stopAnimating()
                self.myLabelArray.first?.text = time.description
                self.myImageViewArray.first?.image = UIImage(data: info.data)
            }
        })
        
        task?.resume()
    }
    
    @IBAction func multiPointResumingDownloadImage(_ sender: UIBarButtonItem) {
        
        let startTime = Date()
        let fragmentCount = 5
        
        indicatorViewArray.last?.startAnimating()
        myImageViewArray.last?.image = nil
        myLabelArray.last?.text = "多點下載 - \(fragmentCount)點"

        let task = multiPointResumingDownloadTaskMaker(with: imageUrlString, fragment: fragmentCount) { (data) in
            
            let time = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
            
            self.indicatorViewArray.last?.stopAnimating()
            self.myLabelArray.last?.text = time.description
            self.myImageViewArray.last?.image = UIImage(data: data)
        }
        
        task?.resume()
    }
    
    deinit { wwPrint("deinit") }
}

// MARK: - 小工具
extension DownloadViewController {

    /// 多點下載 (分割成好幾個部分下載) => 取得檔案的總大小 -> 分段下載 (以Task的id為Key) -> 下載完成就組合起來 (總共的Data加起來為總大小的時候)
    private func multiPointResumingDownloadTaskMaker(with urlString: String, fragment: Int, finish: @escaping ((Data) -> Void)) -> URLSessionTask? {
        
        var dataDictionary: [String: Data] = [:]
        var taskIdentifierArray: [String] = []
        
        let rangeTask = UtilityWeb.shared.responseHeaderFieldTask(with: urlString, field: .contentLength) { (result) in
            
            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let value):
                
                guard let value = value as? String, let fileLength = Int(value) else { return }
                
                let fragmentLength = fileLength / fragment
                
                for index in 0..<fragment {
                    
                    let startOffset = index * fragmentLength
                    let endOffset = (index != fragment - 1) ? (index + 1) * fragmentLength - 1 : nil
                    
                    let resumeTask = UtilityWeb.shared.resumeDownloadRequestTask(with: urlString, offset: (start: startOffset, end: endOffset)) { (result) in
                        
                        switch result {
                        case .failure(let error): wwPrint(error)
                        case .success(let info):
                            
                            let oldData = dataDictionary[info.taskIdentifier] ?? Data()
                            dataDictionary[info.taskIdentifier] = oldData + info.data
                                
                            let totalLength = dataDictionary.values.reduce(0) { (totalLength, data) -> Int in
                                return totalLength + data.count
                            }
                            
                            if totalLength == fileLength {
                                
                                let imageData = taskIdentifierArray.compactMap({ (key) -> Data? in
                                    return dataDictionary[key]
                                }).reduce(Data()) { (sum, data) -> Data in
                                    return sum + data
                                }
                                
                                finish(imageData)
                            }
                        }
                    }
                    
                    if let resumeTask = resumeTask {
                        taskIdentifierArray.append("\(resumeTask)")
                        resumeTask.resume()
                    }
                }
            }
        }
        
        return rangeTask
    }
}
