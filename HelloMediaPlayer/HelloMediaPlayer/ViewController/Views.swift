//
//  Views.swift
//  HelloMediaPlayer
//
//  Created by William.Weng on 2021/5/5.
//

import AVKit
import UIKit

final class MediaTableViewCell: UITableViewCell, CellReusable {
        
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    /// [網址加2個字就好！想下載高畫質YouTube影片 這三個好用網站推薦給你 | 社群網路 | 數位 | 聯合新聞網](https://udn.com/news/story/7088/4681189)
    static var filePaths: [URL] = []
    
    func configure(with indexPath: IndexPath) {
        
        let filePath = Self.filePaths[safe: indexPath.row]
        
        titleLabel.text = filePath?.lastPathComponent
        previewImageView.image = AVAssetImageGenerator._screenshot(url: filePath, maximumSize: CGSize(width: 0, height: 128), time: CMTime(value: 10, timescale: 1), actualTime: nil)
    }
}
