//
//  ViewController.swift
//  AVFoundationVideo
//
//  Created by William.Weng on 2020/2/3.
//  Copyright © 2020 William.Weng. All rights reserved.
//
/// [使用 AVFoundation 進行簡單的視頻錄製](https://www.jianshu.com/p/ca446523fe07)
/// [ios 通過代碼調整焦距](https://www.twblogs.net/a/5d6689bfbd9eee5327feb88f)
/// [iOS中的音頻](https://www.jianshu.com/p/fd4490cbcd22)
/// [iOS 使用 AVCaptureVideoDataOutputSampleBufferDelegate獲取實時拍照的視頻流](https://www.cnblogs.com/cocoajin/p/3494300.html)
/// [iOS 使用相機之 AVFoundation](https://xiaovv.me/2017/09/21/Use-Avfoundation-to-Customize-The-Camera/)
/// [應用 AVFoundation 建立一個全螢幕相機 App](https://www.appcoda.com.tw/avfoundation-camera-app/)
/// [銳動視頻編輯SDK-iOS](https://github.com/rdsdk/rdVideoEditSDK-for-iOS)
/// [ios - 將濾鏡應用於實時相機預覽 - Swift](https://www.ojit.com/article/422617)
/// [iOS 中的CIFilter(基礎用法)](https://juejin.im/post/5d26ac73e51d45108b2caf10)
/// [#74 利用 CIFilter 實現美麗的圖片濾鏡 - 彼得潘的 100 道 Swift iOS App 謎題 - Medium](https://medium.com/彼得潘的試煉-勇者的-100-道-swift-ios-app-謎題/74-利用-cifilter-實現美麗的圖片濾鏡-6b7323612188)

import UIKit
import AVFoundation
import CoreImage.CIFilterBuiltins

// FIXME: Xcode 11.3.1 Used
/// 自定義的Print
public func wwPrint<T>(_ msg: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    Swift.print("🚩 \((file as NSString).lastPathComponent)：\(line) - \(method) \n\t ✅ \(msg)")
    #endif
}

// MARK: - ViewController
class ViewController: UIViewController {

    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var toggleCameraButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var videoTimeLabel: UILabel!
    @IBOutlet weak var filteredImageView: UIImageView!
    @IBOutlet weak var filterMenuButton: UIButton!
    @IBOutlet weak var filterSwitch: UISwitch!
    
    let captureSession = AVCaptureSession()
    let captureOutput = (photo: AVCapturePhotoOutput(), movie: AVCaptureMovieFileOutput(), video: AVCaptureVideoDataOutput())
    let zoomRate: Float = 1.0
    let systemSoundName: (toggle: String, error: String, switch: String) = ("toggle.wav", "error.wav", "switch.wav")
    let maxRecordedSeconds: Float64 = 15
    let zeroTimeLabelText = "00:00:00"
    
    var currentDevice: (video: AVCaptureDevice?, audio: AVCaptureDevice?) = (nil, nil)
    var isRecorder = false
    var movieTimer: Timer?
    var filterEffect: CIFilter = CIFilter.sepiaTone()

    lazy var videoDevice = videoDevices()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSetting()

        addStillImageOutput()
        addGestureRecognizer()

        filteredImageViewSetting()
    }

    deinit { movieTimer?.invalidate() }

    @IBAction func captureMedia(_ sender: UIButton) {

        hideFilterViews(true)
        
        switch isRecorder {
        case true: movieRecorder()
        case false: capturePhoto()
        }
    }

    @IBAction func switchFunction(_ sender: UIButton) {
        hideFilterViews(true)
        switchFunction(with: sender)
        playSystemSound(name: systemSoundName.switch)
    }

    @IBAction func toggleCamera(_ sender: UIButton) {
        toggleCamera()
        playSystemSound(name: systemSoundName.toggle)
    }
    
    @IBAction func showFilterImageView(_ sender: UISwitch) {
        
        switch sender.isOn {
        case true:
            hideFilterViews(false)
            addVideoDataOutput()
        case false:
            hideFilterViews(true)
            removeVideoDelegate()
        }
    }
    
    @IBAction func switchFilter(_ sender: UIButton) {
        let alert = filtersAlertControllerMaker(withTitle: "", message: "請選擇濾鏡") {}
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension ViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let error = error { wwPrint(error); return }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
        else {
            wwPrint("photoOutput error"); return
        }

        savePhotoToAlbum(image)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension ViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        actionButtonStatus(isEnabled: !output.isRecording)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let error = error {
            removeButtonTransfromAnimations(with: startButton)
            movieTimerStop()
            wwPrint(error)
        }
        
        actionButtonStatus(isEnabled: !output.isRecording)
        saveMoiveToAlbum(with: outputFileURL)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        filteredImageView.image = filterImageMaker(effect: filterEffect, sampleBuffer: sampleBuffer)
    }
}

// MARK: - @objc
extension ViewController {
    
    /// 畫面放大
    @objc private func zoomIn() throws {
        
        guard let maxZoomFactor = currentDevice.video?.maxAvailableVideoZoomFactor,
              let currentVideoZoomFactor = currentDevice.video?.videoZoomFactor,
              currentVideoZoomFactor < maxZoomFactor,
              let newZoomFactor = Optional.some(min(currentVideoZoomFactor + CGFloat(zoomRate), maxZoomFactor))
        else {
            return
        }

        do {
            try currentDevice.video?.lockForConfiguration()
            currentDevice.video?.ramp(toVideoZoomFactor: newZoomFactor, withRate: zoomRate)
            currentDevice.video?.unlockForConfiguration()
        } catch {
            throw error
        }
    }
    
    /// 畫面縮小
    @objc private func zoomOut() throws {
        
        guard let minZoomFactor = currentDevice.video?.minAvailableVideoZoomFactor,
              let currentVideoZoomFactor = currentDevice.video?.videoZoomFactor,
              currentVideoZoomFactor > minZoomFactor,
              let newZoomFactor = Optional.some(max(currentVideoZoomFactor - CGFloat(zoomRate), minZoomFactor))
        else {
            return
        }
        
        do {
            try currentDevice.video?.lockForConfiguration()
            currentDevice.video?.ramp(toVideoZoomFactor: newZoomFactor, withRate: zoomRate)
            currentDevice.video?.unlockForConfiguration()
        } catch {
            throw error
        }
    }
    
    /// 儲存照片後的處理
    @objc func imageSaveFinished(image: UIImage?, error: Error?, context: UnsafeRawPointer) {
                
        if let error = error {
            playSystemSound(name: systemSoundName.error)
            wwPrint(error); return
        }
        
        feedBack(style: .heavy)
        shutterAnimaiton()
    }
    
    /// 儲存影片後的處理 (移除Audio輸入)
    @objc func movieSaveFinished(moviePath: String?, error: Error?, context: UnsafeRawPointer) {
        
        if let error = error {
            playSystemSound(name: systemSoundName.error)
            wwPrint(error); return
        }
        
        if let isSuccess = try? canRemoveTempMovie(with: moviePath) {
            
            if (isSuccess) {
                feedBack(style: .heavy)
            } else {
                playSystemSound(name: systemSoundName.error)
            }
        }
        
        removeDeviceSessionInput(withType: .builtInMicrophone)
        currentDevice.audio = nil
    }

    /// 刪除暫存的影片
    private func canRemoveTempMovie(with moviePath: String?) throws -> Bool {
        
        guard let moviePath = moviePath else { return false }
        
            let fileManager = FileManager.default
                        
            do {
                try fileManager.removeItem(at: URL(fileURLWithPath: moviePath))
            } catch {
                throw error
            }
        
        return true
    }
}

// MARK: - 主工具
extension ViewController {
    
    /// 初始化設定 (取得一開始的camera預覽畫面)
    private func initSetting() {
        
        guard let videoDevice = currentDeviceMaker(type: .video),
              canAddDeviceSessionInput(device: videoDevice)
        else {
            return
        }
        
        movieTimeLabelStatus(isRecorder: isRecorder)
        currentDevice.video = videoDevice
        showPreviewLayer(for: captureSession)
    }
    
    /// 顯示PreviewLayer
    private func showPreviewLayer(for session: AVCaptureSession) {
        
        let previewLayer = previewLayerMaker(for: session)

        view.layer.insertSublayer(previewLayer, below: buttonStackView.layer)
        session.startRunning()
    }
    
    /// 切換相機 (前 <=> 後)
    private func toggleCamera() {
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        clearCaptureSessionInputs(captureSession)
        
        guard let videoDevice = (currentDevice.video?.position == .back) ? videoDevice.front : videoDevice.back,
              canAddDeviceSessionInput(device: videoDevice)
        else {
            return
        }
        
        currentDevice.video = videoDevice; return
    }
    
    /// 加入左右滑動的手勢功能 (放大 / 縮小)
    private func addGestureRecognizer() {
        view.addGestureRecognizer(zoomInGestureRecognizerMaker(direction: .right))
        view.addGestureRecognizer(zoomOutGestureRecognizerMaker(direction: .left))
    }

    /// 拍照
    private func capturePhoto() {
        captureOutput.photo.capturePhoto(with: photoSettingsMaker(), delegate: self)
    }
    
    /// 儲存照片到相簿 (NSPhotoLibraryAddUsageDescription)
    private func savePhotoToAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveFinished(image:error:context:)), nil)
    }
    
    /// 錄影 (UIFileSharingEnabled)
    private func movieRecorder() {

        let isRecording = captureOutput.movie.isRecording
        
        if (isRecording) {
            stopRecording()
        } else {
            startRecording(withSeconds: maxRecordedSeconds)
        }
        
        movieTimerRunning(!isRecording)
    }
    
    /// 切換功能 (拍照 <=> 錄影)
    private func switchFunction(with sender: UIButton) {
        
        isRecorder.toggle()
        movieTimeLabelStatus(isRecorder: isRecorder)

        if (isRecorder) {
            addMovieFileOutput()
            sender.setImage(#imageLiteral(resourceName: "video_recorder"), for: .normal)
        } else {
            addStillImageOutput()
            sender.setImage(#imageLiteral(resourceName: "shutter"), for: .normal)
        }
    }
    
    /// 記錄影片的錄製時間
    private func movieTimerRunning(_ running: Bool = true) {
        
        if (running) {
            movieTimerStart()
        } else {
            movieTimerStop()
        }
    }
    
    /// 儲存Movie到相簿
    private func saveMoiveToAlbum(with outputFileURL: URL) {
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path) {
            DispatchQueue.global().async {
                UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(self.movieSaveFinished(moviePath:error:context:)), nil)
            }
        }
    }
}

// MARK: - 小工具 (相機)
extension ViewController {
    
    /// 取得預設裝置 (NSCameraUsageDescription / NSMicrophoneUsageDescription)
    private func currentDeviceMaker(type: AVMediaType) -> AVCaptureDevice? {
        guard let currentDevice = AVCaptureDevice.default(for: type) else { return nil }
        return currentDevice
    }
    
    /// 取得裝置的Input
    private func captureCurrentDeviceInput(device: AVCaptureDevice) throws -> AVCaptureDeviceInput? {
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            return deviceInput
        } catch {
            throw error
        }
    }
    
    /// 將Input加入Session
    private func canAddDeviceInputForSession(_ input: AVCaptureDeviceInput) -> Bool {
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input); return true
        }

        return false
    }
    
    /// 產生、設定PreviewLayer
    private func previewLayerMaker(for session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }
    
    /// 取得所有的Video的設備
    private func videoDevices() -> (front: AVCaptureDevice?, back: AVCaptureDevice?) {
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices

        var videoDeivce: (front: AVCaptureDevice?, back: AVCaptureDevice?) = (nil, nil)
        
        for device in devices {
            switch device.position {
            case .front: videoDeivce.front = device
            case .back: videoDeivce.back = device
            case .unspecified: break
            @unknown default: fatalError()
            }
        }
                
        return videoDeivce
    }
    
    /// 清除所有的SessionInput
    private func clearCaptureSessionInputs(_ captureSession: AVCaptureSession) {
        
        for input in captureSession.inputs {
            
            if let input = input as? AVCaptureDeviceInput {
                captureSession.removeInput(input)
            }
        }
    }
    
    /// 加上Session的DeviceInput
    private func canAddDeviceSessionInput(device: AVCaptureDevice) -> Bool {
        
        guard let deviceInput = try? captureCurrentDeviceInput(device: device),
              canAddDeviceInputForSession(deviceInput)
        else {
            return false
        }
        
        return true
    }
    
    /// 移除Session的DeviceInput
    private func removeDeviceSessionInput(withType type: AVCaptureDevice.DeviceType) {
                
        for input in captureSession.inputs {
            
            guard let input = input as? AVCaptureDeviceInput,
                  input.device.deviceType == type
            else {
                continue
            }
            
            captureSession.removeInput(input)
        }
    }

    /// 產生SwipeGestureRecognizer (放大)
    private func zoomInGestureRecognizerMaker(direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        
        let zoomInGestureRecognizer = UISwipeGestureRecognizer()
        
        zoomInGestureRecognizer.direction = direction
        zoomInGestureRecognizer.addTarget(self, action: #selector(zoomIn))
        
        return zoomInGestureRecognizer
    }
    
    /// 產生SwipeGestureRecognizer (縮小)
    private func zoomOutGestureRecognizerMaker(direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        
        let zoomInGestureRecognizer = UISwipeGestureRecognizer()
        
        zoomInGestureRecognizer.direction = direction
        zoomInGestureRecognizer.addTarget(self, action: #selector(zoomOut))
        
        return zoomInGestureRecognizer
    }
}

// MARK: - 小工具 (照片)
extension ViewController {
    
    /// 加入靜態圖片輸出的Output
    private func addStillImageOutput() {
        clearCaptureSessionOutputs(with: captureSession)
        captureOutput.photo.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(captureOutput.photo)
    }
    
    /// 擷圖的設定
    private func photoSettingsMaker() -> AVCapturePhotoSettings {
        
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])

        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        return photoSettings
    }
    
    /// 震動反饋 (iOS 10)
    private func feedBack(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        
        let feedBackGenertor = UIImpactFeedbackGenerator(style: style)
        feedBackGenertor.impactOccurred()
    }
    
    /// 播放聲音
    private func playSystemSound(name: String) {

        guard let path = Bundle.main.path(forResource: name, ofType: nil),
              let baseURL = Optional.some(NSURL(fileURLWithPath: path))
        else {
            return
        }
        
        var soundID: SystemSoundID = 0
        
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    /// 拍照動畫 (透明度變化)
    private func shutterAnimaiton(duration: TimeInterval = 1.0) {
        
        view.alpha = 0.0
        UIView.animate(withDuration: duration) { self.view.alpha = 1.0 }
    }
}

// MARK: - 小工具 (錄影)
extension ViewController {
    
    /// 按鍵縮放動畫
    private func buttonZoomAnimation(with sender: UIButton) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: nil)
    }
    
    /// 清除所有的SessionOutput
    private func clearCaptureSessionOutputs(with captureSession: AVCaptureSession) {
        
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
    }

    /// 加入Movie輸出的Output
    private func addMovieFileOutput() {
        clearCaptureSessionOutputs(with: captureSession)
        captureSession.sessionPreset = .high
        captureSession.addOutput(captureOutput.movie)
    }

    /// 開始錄影 (加入Audio輸入)
    private func startRecording(withSeconds seconds: Float64) {
        
        if canAddAudioDeviceInputForSession(), let tempOutputFileURL = movieFileOutputURLMaker() {
            buttonZoomAnimation(with: startButton)
            captureOutput.movie.maxRecordedDuration = maxRecordedDurationMaker(seconds: seconds)
            captureOutput.movie.startRecording(to: tempOutputFileURL, recordingDelegate: self)
        }
    }
    
    /// 停止錄影
    private func stopRecording() {
        removeButtonTransfromAnimations(with: startButton)
        captureOutput.movie.stopRecording()
    }
    
    /// 移除ButttonTransfrom動畫
    private func removeButtonTransfromAnimations(with button: UIButton) {
        startButton.layer.removeAllAnimations()
        startButton.transform = .identity
    }
    
    /// 產生影片的檔名路徑URL
    private func movieFileOutputURLMaker() -> URL? {
        
        guard let documentDirectoryURL = documentDirectoryURL() else { return nil }
        
        let filename = "\(Date()).mov"
        return documentDirectoryURL.appendingPathComponent(filename)
    }

    /// 取得DocumentDirectoryURL
    private func documentDirectoryURL() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }

    /// 設定其它動作按鍵的狀態
    private func actionButtonStatus(isEnabled: Bool) {
        switchButton.isEnabled = isEnabled
        toggleCameraButton.isEnabled = isEnabled
        filterSwitch.isEnabled = isEnabled
    }
    
    /// 計時Label的顯示與否
    private func movieTimeLabelStatus(isRecorder: Bool) {
                
        if (!isRecorder) { videoTimeLabel.text = zeroTimeLabelText }
        videoTimeLabel.isHidden = !isRecorder
    }
    
    /// 開始計時
    private func movieTimerStart() {
        
        let currentDate = Date()
        let timeInterval: TimeInterval = 1
        
        movieTimeLabelStatus(isRecorder: isRecorder)
        
        movieTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { (timer) in
            self.videoTimeLabel.text = self.movieRunningTimeIntervalMaker(with: timer, for: currentDate)
        }
        
        movieTimer?.fire()
    }
    
    /// 停止計時
    private func movieTimerStop() {
        movieTimeLabelStatus(isRecorder: isRecorder)
        movieTimer?.invalidate()
        movieTimer = nil
    }
    
    /// 計時的功能 (1970-01-01 00:00:30 +0000 => 00:00:30)
    private func movieRunningTimeIntervalMaker(with timer: Timer, for currentDate: Date) -> String {
        
        let deltaTimeInterval = timer.timeInterval - currentDate.timeIntervalSince1970 - 1
        let dateString = (Date(timeIntervalSinceNow: deltaTimeInterval)).description
        let pattern = "[0-9]{2}:[0-9]{2}:[0-9]{2}"
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let nsRange = Optional.some(NSRange(dateString.startIndex..., in: dateString)),
              let result = regex.matches(in: dateString, range: nsRange).first,
              let range = Range(result.range, in: dateString),
              let resultString = Optional.some(dateString[range])
        else {
            return zeroTimeLabelText
        }
        
        return "\(resultString)"
    }
    
    /// 加入Audio到Session中
    private func canAddAudioDeviceInputForSession() -> Bool {
        
        guard let audioDevice = currentDeviceMaker(type: .audio),
              canAddDeviceSessionInput(device: audioDevice)
        else {
            return false
        }
        
        currentDevice.audio = audioDevice
        
        return true
    }

    /// 最多錄幾秒 (CMTime)
    private func maxRecordedDurationMaker(seconds: Float64) -> CMTime {
        return CMTimeMakeWithSeconds(seconds, preferredTimescale: Int32(1 * NSEC_PER_SEC))
    }
}

// MARK: - 小工具 (濾鏡)
extension ViewController {
    
    /// 加入Video輸出的Output
    private func addVideoDataOutput() {

        clearCaptureSessionOutputs(with: captureSession)
        
        captureOutput.video.setSampleBufferDelegate(self, queue: .main)

        captureSession.sessionPreset = .high
        captureSession.addOutput(captureOutput.video)
    }
    
    /// 濾鏡ImageView的基本設定
    private func filteredImageViewSetting() {
        view.layer.insertSublayer(filteredImageView.layer, below: buttonStackView.layer)
        hideFilterViews(true)
    }
    
    /// 是否要隱藏濾鏡相關View
    private func hideFilterViews(_ isHidden: Bool) {
        filteredImageView.isHidden = isHidden
        filterMenuButton.isHidden = isHidden
    }

    /// 修正CIImage方向的問題 (把圖轉個方向)
    private func fixCIImageOrientationMaker(_ ciImage: CIImage) -> CIImage? {
        
        guard let videoPosition = currentDevice.video?.position else { return nil }
                
        switch videoPosition {
        case .front: return ciImage.oriented(.right).oriented(.upMirrored)
        case .back: return ciImage.oriented(.right)
        case .unspecified: return ciImage
        @unknown default: fatalError()
        }
    }
    
    /// 產生有濾鏡效果的image
    private func filterImageMaker(effect: CIFilter, sampleBuffer: CMSampleBuffer) -> UIImage? {

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let ciImage = imageBufferToCIImage(imageBuffer: imageBuffer, by: effect),
              let orientedCIImage = fixCIImageOrientationMaker(ciImage),
              let image = Optional.some(UIImage(ciImage: orientedCIImage))
        else {
            return nil
        }
                
        return image
    }
    
    /// CVImageBuffer => CIImage
    private func imageBufferToCIImage(imageBuffer: CVImageBuffer, by effect: CIFilter) -> CIImage? {
                
        let cameraImage = CIImage(cvImageBuffer: imageBuffer)
        effect.setValue(cameraImage, forKey: kCIInputImageKey)
        
        return effect.value(forKey: kCIOutputImageKey) as? CIImage
    }

    /// 移除濾鏡的Delegate
    private func removeVideoDelegate() {
        captureOutput.video.setSampleBufferDelegate(nil, queue: nil)
    }
    
    /// 選濾鏡的AlertController
    private func filtersAlertControllerMaker(withTitle title: String, message: String, cancelAction: @escaping () -> Void) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in cancelAction() }
        let filters: [CIFilter] = [CIFilter.comicEffect(), CIFilter.colorMonochrome(), CIFilter.sepiaTone()]
        
        for index in 0..<filters.count {
            let filterAction = UIAlertAction(title: "濾鏡 \(index + 1)", style: .default) { (_) in self.filterEffect = filters[index] }
            alertController.addAction(filterAction)
        }
        
        alertController.addAction(cancelAction)
        
        return alertController
    }
}
