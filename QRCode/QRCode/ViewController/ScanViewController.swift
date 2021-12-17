//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2021/9/15.
//  ~/Library/Caches/org.swift.swiftpm/

import UIKit
import AVFoundation
import WWPrint

public protocol ScanDelegate: AnyObject {
    
    /// [取得掃瞄到的結果](https://ithelp.ithome.com.tw/articles/10197599)
    func metadataOutput(_ result: Result<AVMetadataMachineReadableCodeObject, Error>)
}

final class ScanViewController: UIViewController {
    
    /// 自訂錯誤
    enum MyError: Error, LocalizedError {
        
        var errorDescription: String { errorMessage() }

        case unknown
        case notSupports
        
        /// 顯示錯誤說明
        /// - Returns: String
        private func errorMessage() -> String {

            switch self {
            case .unknown: return "未知錯誤"
            case .notSupports: return "該手機不支援"
            }
        }
    }
    
    private let captureSession = AVCaptureSession()
    private let captureMetadataOutput = AVCaptureMetadataOutput()
    
    private var scanTypes: [AVMetadataObject.ObjectType] = [.qr]
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var callbackQueue: DispatchQueue? = .main
    
    private weak var myDelegate: ScanDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
                
        guard let metadataObject = metadataObjects.first,
              let transformedMetadataObject = previewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject
        else {
            myDelegate?.metadataOutput(.failure(MyError.notSupports)); return
        }
        
        myDelegate?.metadataOutput(.success(transformedMetadataObject))
    }
}

// MARK: - 設定
extension ScanViewController {
    
    /// [設定可以掃到的類型](https://www.appcoda.com.tw/qr-code-reader-swift/)
    /// - Parameters:
    ///   - types: 設定可以掃到的類型
    ///   - delegate: ScanDelegate
    ///   - queue: DispatchQueue?
    public func configure(types: [AVMetadataObject.ObjectType], delegate: ScanDelegate, queue: DispatchQueue? = .main) {
        scanTypes = types
        myDelegate = delegate
        callbackQueue = queue
    }
    
    /// [開啟掃瞄](http://www.appsbarcode.com/code%20128.php)
    public func startRunning() { captureSession.startRunning() }
    
    /// [關閉掃瞄](https://www.cool3c.com/article/150348)
    public func stopRunning() { captureSession.stopRunning() }
}

// MARK: - 小工具
extension ScanViewController {
    
    /// [取得鏡頭 / NSCameraUsageDescription](https://medium.com/彼得潘的-swift-ios-app-開發教室/qrcode掃起來-24e086df902c)
    private func initSetting() {
        
        guard let device = AVCaptureDevice._default(for: .video),
              let input = try? device._captureInput().get(),
              let previewLayer = Optional.some(captureSession._previewLayer(with: view.bounds, videoGravity: .resizeAspectFill)),
              captureSession._canAddInput(input),
              captureSession._canAddOutput(captureMetadataOutput)
        else {
            return
        }
        
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
        qrcodeOutputSetting(types: scanTypes)
    }
    
    /// [AVCaptureMetadataOutputObjectsDelegate](https://developer.apple.com/documentation/avfoundation/avcapturemetadataoutputobjectsdelegate/1389481-metadataoutput)
    private func qrcodeOutputSetting(types : [AVMetadataObject.ObjectType]) {
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: callbackQueue)
        captureMetadataOutput.metadataObjectTypes = types
    }
}


