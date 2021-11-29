//
//  Extension+.swift
//  QRCode
//
//  Created by William.Weng on 2021/11/29.
//

import AVFoundation
import UIKit

// MARK: - AVCaptureDevice (static function)
extension AVCaptureDevice {
    
    /// 取得預設影音裝置 (NSCameraUsageDescription / NSMicrophoneUsageDescription)
    static func _default(for type: AVMediaType) -> AVCaptureDevice? { return AVCaptureDevice.default(for: type) }
}

// MARK: - AVCaptureDevice (class function)
extension AVCaptureDevice {
    
    /// 判斷鏡頭的位置 (前後) => .front / .back
    func _videoPosition() -> AVCaptureDevice.Position { return self.position }
    
    /// 取得裝置的Input => NSCameraUsageDescription / NSMicrophoneUsageDescription
    func _captureInput() -> Result<AVCaptureDeviceInput, Error> {
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: self)
            return .success(deviceInput)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - AVCaptureSession (class function)
extension AVCaptureSession {
    
    /// 產生、設定AVCaptureVideoPreviewLayer
    /// - Parameters:
    ///   - frame: CGRect
    ///   - videoGravity: AVLayerVideoGravity => .resizeAspectFill
    /// - Returns: AVCaptureVideoPreviewLayer
    func _previewLayer(with frame: CGRect, videoGravity: AVLayerVideoGravity = .resizeAspectFill) -> AVCaptureVideoPreviewLayer {
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self)
        
        previewLayer.frame = frame
        previewLayer.videoGravity = videoGravity
        
        return previewLayer
    }
 
    /// 將影音的Input加入Session
    /// - Parameter input: AVCaptureInput
    /// - Returns: Bool
    func _canAddInput(_ input: AVCaptureInput) -> Bool {
        guard self.canAddInput(input) else { return false }
        self.addInput(input); return true
    }
    
    /// 將影音的Output加入Session
    /// - Parameter input: AVCaptureOutput
    /// - Returns: Bool
    func _canAddOutput(_ output: AVCaptureOutput) -> Bool {
        guard self.canAddOutput(output) else { return false }
        self.addOutput(output); return true
    }
}

// MARK: - UIImpactFeedbackGenerator (static function)
extension UIImpactFeedbackGenerator {
    
    /// 產生震動物件 => UIImpactFeedbackGenerator(style: style)
    /// - Parameter style: 震動的類型
    static func _build(style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator { return UIImpactFeedbackGenerator(style: style) }
    
    /// 產生震動 => impactOccurred()
    static func _impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let feedbackGenerator = Self._build(style: style)
        feedbackGenerator._impact()
    }
}

// MARK: - UIImpactFeedbackGenerator (static function)
extension UIImpactFeedbackGenerator {
    
    /// 產生震動 => impactOccurred()
    func _impact() { self.impactOccurred() }
}
