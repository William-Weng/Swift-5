//
//  FileViewController.swift
//  View3DModel
//
//  Created by William-Weng on 2019/2/19.
//  Copyright © 2019年 William-Weng. All rights reserved.
//
/// [SceneKit動態加載.dae模型步驟詳解](https://www.jianshu.com/p/429c91deabcc)
/// [Swift 檔案路徑與讀寫檔](https://cdfq152313.github.io/post/2016-10-11/)
/// [Swift 入門教學：知錯能改善莫大焉的 Error Handling](https://www.appcoda.com.tw/swift-error-handling/)
/// [如何在SCENEKIT使用SWIFT RUNTIME動態加載COLLADA文件](https://www.cnblogs.com/bigger/p/4985421.html)

import UIKit
import SceneKit
import AssetImportKit

// MARK: - FileViewController
class FileViewController: UIViewController {

    /// Model檔的副檔名類型
    enum FileExtensionType: String {
        case scn = "scn"
        case dae = "dae"
        case obj = "obj"
        case blend = "blend"
        case fbx = "fbx"
    }
    
    @IBOutlet weak var myTableView: UITableView!
    
    weak var myDelegate: SceneDelegate?
    
    var modelFilenames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetting()
        readFilenames()
    }
    
    deinit {
        print("FileViewController deinit")
    }
}

// MARK: - 設定
extension FileViewController {
    
    /// TableView初始化設定
    private func tableViewSetting() {
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    /// 讀取使用者Documents的內的檔案名稱
    private func readFilenames() {
        
        if let filenames = documentsFilenamesMaker() {
            modelFilenames = filenames
            myTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension FileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelFilenames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier()) else {
            return UITableViewCell()
        }
        
        let row = indexPath.row
        cell.textLabel?.text = modelFilenames[row]
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let scene = seleectedModelSceneMaker(with: indexPath) {
            myDelegate?.updataScene(scene)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - 主工具
extension FileViewController {
    
    /// 產生被選到的檔案場景
    private func seleectedModelSceneMaker(with indexPath: IndexPath) -> SCNScene? {
        
        let filename = modelFilenames[indexPath.row]
        let fileUrl = documentsFileUrlMaker(with: filename)
        let scene: SCNScene?
        
        guard let fileType = fileExtensionType(with: fileUrl) else { return nil }
        
        switch fileType {
        case .scn: scene = scnModelSceneMaker(with: fileUrl)
        default: scene = daeModelSceneMaker(with: fileUrl)
        }
        
        return scene
    }
}

// MARK: - Scene小工具
extension FileViewController {
    
    /// 將.scn轉換成SCNScene
    private func scnModelSceneMaker(with fileURL: URL?) -> SCNScene? {
        
        guard let fileURL = fileURL,
              FileManager.default.fileExists(atPath: fileURL.path)
        else {
            return nil
        }
        
        return try? SCNScene(url: fileURL, options: nil)
    }
    
    /// 將.dae轉換成SCNScene
    private func daeModelSceneMaker(with fileURL: URL?) -> SCNScene? {
        
        guard let filePath = fileURL?.path,
              let assimpScene = try? SCNScene.assimpScene(filePath: filePath, postProcessSteps: [.defaultQuality])
        else {
            return nil
        }
                
        return assimpScene.modelScene
    }
}

// MARK: - 小工具
extension FileViewController {
    
    /// 取得Cell的ReuseIdentifier
    private func cellReuseIdentifier() -> String {
        let identifier = "ModelCell"
        return identifier
    }
    
    /// 取得Document的URL
    private func documentsUrlMaker() -> URL? {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first
        
        return documentsDirectory
    }
    
    /// 讀取檔案名稱
    private func documentsFilenamesMaker() -> [String]? {
        
        guard let documentsPath = documentsUrlMaker()?.path else { return nil }
        let fileList = try? FileManager.default.contentsOfDirectory(atPath: documentsPath)
        
        return fileList?.sorted()
    }
    
    /// 取得外部檔案完整的URL
    private func documentsFileUrlMaker(with name: String) -> URL? {
        let filePath = documentsUrlMaker()?.appendingPathComponent(name)
        return filePath
    }
    
    /// 根據檔案的URL判斷Type
    private func fileExtensionType(with fileURL: URL?) -> FileExtensionType? {
        
        guard let fileExtension = pathExtension(with: fileURL),
              let fileExtensionType = FileExtensionType(rawValue: fileExtension)
        else {
            return nil
        }
        
        return fileExtensionType
    }
    
    /// 取得檔案路徑的副檔名 (小寫)
    private func pathExtension(with fileURL: URL?) -> String? {
        
        guard let url = fileURL else { return nil }
        let pathExtension = url.pathExtension
        
        return pathExtension.lowercased()
    }
}



