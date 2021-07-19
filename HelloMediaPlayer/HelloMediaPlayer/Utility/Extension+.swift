//
//  Extension+.swift
//  HelloMediaPlayer
//
//  Created by William.Weng on 2021/5/4.
//

import AVKit

// MARK: - Collection (override class function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - URL (static function)
extension URL {
    
    /// User的「文件」資料夾URL
    /// - => ~/Documents
    /// - Returns: URL?
    static func _documentDirectory() -> URL? { return _userDirectory(for: .documentDirectory).first }
    
    /// [取得User的資料夾](https://cdfq152313.github.io/post/2016-10-11/)
    /// - UIFileSharingEnabled = YES => iOS設置iTunes文件共享
    /// - Parameter directory: User的資料夾名稱
    /// - Returns: [URL]
    static func _userDirectory(for directory: FileManager.SearchPathDirectory) -> [URL] { return FileManager.default.urls(for: directory, in: .userDomainMask) }
}

// MARK: - URL (class function)
extension URL {
    
    /// 取得該路徑的檔案名稱
    /// - Returns: [String]?
    func _filenames() -> [String]? {
        
        guard let fileList = try? FileManager.default.contentsOfDirectory(atPath: self.path) else { return nil }
        return fileList.sorted()
    }
}

// MARK: - UIView (class function)
extension UIView {
    
    /// 擷取UIView的畫面
    /// - Returns: UIImage
    func _screenshot() -> UIImage {

        let render = UIGraphicsImageRenderer(size: bounds.size)
        let image = render.image { (_) in drawHierarchy(in: bounds, afterScreenUpdates: true) }
        
        return image
    }
}

// MARK: - UITableView (class function)
extension UITableView {
    
    /// 取得UITableViewCell
    /// - let cell = tableview._reusableCell(at: indexPath) as MyTableViewCell
    /// - Parameter indexPath: IndexPath
    /// - Returns: 符合CellReusable的Cell
    func _reusableCell<T: CellReusable>(at indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else { fatalError("UITableViewCell Error") }
        return cell
    }
}

// MARK: - AVPlayer (static function)
extension AVPlayer {
    
    /// 產生Player
    /// - 可以加上某一個UIView上面 (定位)
    /// - Parameters:
    ///   - videoURL: 影片的URL
    ///   - baseView: 要貼在哪個View上
    /// - Returns: AVPlayer
    static func _build(videoURL: URL, on baseView: UIView? = nil) -> AVPlayer {
        
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)

        if let baseView = baseView {
            playerLayer.frame = baseView.bounds
            baseView.layer.addSublayer(playerLayer)
        }
        
        return player
    }
}

// MARK: - AVPlayerViewController (static function)
extension AVPlayerViewController {
    
    /// 產生PlayerController
    /// - Parameter videoURL: 影片的URL
    /// - Returns: AVPlayerViewController
    static func _build(videoURL: URL, on baseView: UIView? = nil) -> AVPlayerViewController {
        
        let playerController = AVPlayerViewController()
        let player = AVPlayer._build(videoURL: videoURL, on: baseView)
        
        playerController.player = player
        
        return playerController
    }
    
    /// 產生PlayerController
    /// - Parameter player: AVPlayer
    /// - Returns: AVPlayerViewController
    static func _build(player: AVPlayer) -> AVPlayerViewController {
        
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        return playerController
    }
}

// MARK: - AVAssetImageGenerator (class function)
extension AVAssetImageGenerator {
    
    /// [AVPlayerLayer擷圖](https://stackoverflow.com/questions/42020130/swift-how-to-take-screenshot-of-avplayerlayer)
    /// - Parameters:
    ///   - url: 影片的URL
    ///   - maximumSize: 擷圖的最大尺寸 => CGSize(width: 0, height: 128)
    ///   - time: 擷該時間的圖像 => CMTime(value: 3, timescale: 1)
    ///   - actualTime: 時間的時間 => nil
    /// - Returns: UIImage?
    static func _screenshot(url: URL?, maximumSize: CGSize = CGSize(width: 0, height: 128), time: CMTime = .zero, actualTime: UnsafeMutablePointer<CMTime>? = nil) -> UIImage? {
        
        guard let url = url else { return nil }
        
        let asset = AVAsset(url: url)
        let imageGenerator = Self(asset: asset)
        
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        imageGenerator.maximumSize = maximumSize
        
        guard let cgImage: CGImage = try? imageGenerator.copyCGImage(at: time, actualTime: actualTime) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
