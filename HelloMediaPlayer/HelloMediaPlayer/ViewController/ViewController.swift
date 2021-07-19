//
//  ViewController.swift
//  HelloMediaPlayer
//
//  Created by William.Weng on 2021/5/4.
//

import UIKit
import AVKit

final class ViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    private let fileExtensionTypeSet: Set<String> = ["mp4", "mov"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }

    deinit { wwPrint("deinit") }
    
    @IBAction func refreshData(_ sender: UIBarButtonItem) {
        myTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return MediaTableViewCell.filePaths.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView._reusableCell(at: indexPath) as MediaTableViewCell
        cell.configure(with: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let filePath = MediaTableViewCell.filePaths[safe: indexPath.row] else { return }
        
        let playerViewController = AVPlayerViewController._build(videoURL: filePath)
        present(playerViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {}
}

// MARK: - 自定義 FilePathDelegate
extension ViewController: FilePathDelegate {
    
    func updateFilePath(url: URL) {
        MediaTableViewCell.filePaths.append(url)
        myTableView.reloadData()
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 初始化設定
    private func initSetting() {
        
        MediaTableViewCell.filePaths = filePathFilter(urls: documentDirectoryFilePaths(), filters: fileExtensionTypeSet)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate { appDelegate.myDelegate = self }
        
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    /// 取得Document下的檔案路徑 => file:///var/mobile/Containers/Data/Application/<Hash>/Documents/demo.mov
    /// - Returns: [URL]
    private func documentDirectoryFilePaths() -> [URL] {
        
        guard let documentDirectory = URL._documentDirectory(),
              let filenames = documentDirectory._filenames()
        else {
            return []
        }
        
        let filePaths = filenames.map { filename in
            return documentDirectory.appendingPathComponent(filename)
        }
        
        return filePaths
    }
    
    /// 過濾符合的副檔名
    /// - Parameter urls: [URL]
    /// - Returns: [URL]
    private func filePathFilter(urls: [URL], filters: Set<String>) -> [URL] {
        
        let paths = urls.filter { url in
            return filters.contains(url.pathExtension)
        }
        
        return paths
    }
}
