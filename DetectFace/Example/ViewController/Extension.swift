//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2022/1/22.
//

import UIKit
import AVKit
import Vision

// MARK: - Collection (class function)
extension Collection where Self.Element: CALayer {
    
    /// 將所有CALayer移除
    func _removeFromSuperlayer() {
        self.forEach { $0.removeFromSuperlayer() }
    }
}

// MARK: - CGRect (class function)
extension CGRect {
    
    /// [將取得的比例大小 => 位置](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/83-利用-cgaffinetransform-縮放-位移和旋轉-e061df9ed672)
    /// - Parameters:
    ///   - scaleX: CGFloat
    ///   - scaleY: CGFloat
    ///   - frame: [CGRect](https://medium.com/彼得潘的-swift-ios-app-開發教室/作業-52-使用-swiftui-預覽-uibezierpath-畫出喜歡角落的貓咪-ed4042a23303)
    /// - Returns: CGRect
    func _convertRatio(scaleX: CGFloat = 1.0, scaleY: CGFloat = 1.0, to frame: CGRect) -> CGRect {
        
        let size = frame.size
        let scaleTranslate = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
        let frameTransform = CGAffineTransform(scaleX: scaleX, y: scaleY).translatedBy(x: 0 - frame.origin.x, y: -size.height - frame.origin.y)
        
        return self.applying(scaleTranslate).applying(frameTransform)
    }
}

// MARK: - CALayer (class function)
extension CALayer {
    
    /// 設定frame
    /// - Parameter frame: CGRect
    /// - Returns: Self
    func _frame(_ frame: CGRect) -> Self { self.frame = frame; return self }
    
    /// 設定框線寬度
    /// - Parameter width: CGFloat
    /// - Returns: Self
    func _borderWidth(_ width: CGFloat) -> Self { self.borderWidth = width; return self }
    
    /// 設定框線顏色
    /// - Parameter color: UIColor
    /// - Returns: Self
    func _borderColor(_ color: UIColor) -> Self { self.borderColor = color.cgColor; return self }
    
    /// 設定背景顏色
    /// - Parameter color: UIColor
    /// - Returns: Self
    func _backgroundColor(_ color: UIColor) -> Self { self.backgroundColor = color.cgColor; return self }
}

// MARK: - CIImage (class function)
extension CIImage {
    
    /// [CIImage => CGImage](https://stackoverflow.com/questions/42997462/convert-cmsamplebuffer-to-uiimage)
    /// - Parameter options: [CIContextOption : Any]
    /// - Returns: CGImage?
    func _cgImage(options: [CIContextOption : Any]? = nil) -> CGImage? {
        return CIContext(options: options).createCGImage(self, from: self.extent)
    }
    
    /// [CIImage => UIImage](https://stackoverflow.com/questions/42997462/convert-cmsamplebuffer-to-uiimage)
    /// - Parameters:
    ///   - scale: [CGFloat](https://blog.csdn.net/iTaacy/article/details/69258116)
    ///   - orientation: [UIImage.Orientation](https://developer.apple.com/documentation/uikit/uiimage/1624147-cgimage)
    /// - Returns: UIImage?
    func _createUIImage(scale: CGFloat = 1.0, orientation: UIImage.Orientation = .right) -> UIImage? {
        guard let cgImage = self._cgImage(options: nil) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
}

// MARK: - UIImage (class function)
extension UIImage {
    
    /// UIImage (圖片) => CGImage (點陣圖)
    /// - Returns: CGImage?
    func _cgImage() -> CGImage? { return self.cgImage }
    
    /// [UIImage (圖片) => CGImage (點陣圖) => CIImage (圖片資訊)](https://www.itread01.com/p/350908.html)
    /// - Returns: CIImage?
    func _ciImage() -> CIImage? {
        guard let cgImage = self._cgImage() else { return nil }
        return CIImage(cgImage: cgImage)
    }
    
    /// 修正圖片在Exif上的方向設定值
    /// - 重畫一張
    /// - Returns: UIImage?
    func _normalized() -> UIImage? {
        
        guard imageOrientation != .up else { return self }

        let normalizedImage = _resized(for: size)
        return normalizedImage
    }
    
    /// 改變圖片大小
    /// - Parameter size: 設定的大小
    /// - Returns: UIImage
    func _resized(for size: CGSize) -> UIImage {

        let renderer = UIGraphicsImageRenderer(size: size)
        let resizeImage = renderer.image { (context) in draw(in: renderer.format.bounds) }
        
        return resizeImage
    }
    
    /// [人臉關鍵點提取的結果](https://medium.com/msapps-development/face-recognition-ios-fadfecb99b15)
    /// - Parameters:
    ///   - dispatchQueue: DispatchQueue
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<VNRequest, Error>
    func _detectFaceLandmarksResult(dispatchQueue: DispatchQueue = .global(), options: [VNImageOption : Any] = [:], result: @escaping (Result<[VNFaceObservation]?, Error>) -> ()) {
        self._detectFaceResults(for: VNDetectFaceLandmarksRequest.self, result: result)
    }
    
    /// [人臉辨識](https://medium.com/@zhgchgli/vision-初探-app-頭像上傳-自動識別人臉裁圖-swift-9a9aa892f9a9)
    /// - Parameters:
    ///   - dispatchQueue: [DispatchQueue](https://juejin.cn/post/6844903504469819399)
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<VNRequest, Error>
    func _detectFaceRectanglesRequest(dispatchQueue: DispatchQueue = .global(), options: [VNImageOption : Any] = [:], result: @escaping (Result<VNRequest, Error>) -> ()) {
        self._detectFaceRequest(for: VNDetectFaceRectanglesRequest.self, dispatchQueue: dispatchQueue, options: options, result: result)
    }
    
    /// [人臉關鍵點提取](https://www.jianshu.com/p/59b43dbe4fbd)
    /// - Parameters:
    ///   - dispatchQueue: DispatchQueue
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<VNRequest, Error>
    func _detectFaceLandmarksRequest(dispatchQueue: DispatchQueue = .global(), options: [VNImageOption : Any] = [:], result: @escaping (Result<VNRequest, Error>) -> ()) {
        self._detectFaceRequest(for: VNDetectFaceLandmarksRequest.self, dispatchQueue: dispatchQueue, options: options, result: result)
    }
    
    /// [識別人臉的結果](https://www.jianshu.com/p/83aa3983ac76)
    /// - Parameters:
    ///   - dispatchQueue: DispatchQueue
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<[VNFaceObservation]?, Error>
    func _detectFaceRectanglesResult(dispatchQueue: DispatchQueue = .global(), options: [VNImageOption : Any] = [:], result: @escaping (Result<[VNFaceObservation]?, Error>) -> ()) {
        self._detectFaceResults(for: VNDetectFaceRectanglesRequest.self, result: result)
    }
    
    /// [辨識圖片上人臉的位置 => 滿版](https://www.raywenderlich.com/19454476-vision-tutorial-for-ios-detect-body-and-hand-pose)
    /// - Parameters:
    ///   - frame: 對應要顯示的UIView大小
    ///   - dispatchQueue: DispatchQueue
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<[CGRect]?, Error>
    func _detectFaceRectanglesBox(mirrorTo frame: CGRect, dispatchQueue: DispatchQueue = .global(), options: [VNImageOption : Any] = [:], result: @escaping (Result<[CGRect]?, Error>) -> ()) {
        
        self._detectFaceRectanglesResult(dispatchQueue: dispatchQueue, options: options) { detectResult in
            
            switch detectResult {
            case .failure(let error): result(.failure(error))
            case .success(let detectResults):
                
                guard let detectResults = detectResults else { return result(.success(nil)) }
                
                DispatchQueue.main.async {
                    let faceBoxs = detectResults.compactMap { $0._convertRatio(mirrorTo: frame) }
                    result(.success(faceBoxs))
                }
            }
        }
    }
}

// MARK: - UIImage (private class function)
private extension UIImage {
    
    /// [取得識別人臉的結果](https://www.jianshu.com/p/83aa3983ac76)
    /// - Parameters:
    ///   - type: T: VNImageBasedRequest
    ///   - dispatchQueue: DispatchQueue
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<[VNFaceObservation]?, Error>
    func _detectFaceResults<T: VNImageBasedRequest>(for type: T.Type, dispatchQueue: DispatchQueue = .global(), options: [VNImageOption : Any] = [:], result: @escaping (Result<[VNFaceObservation]?, Error>) -> ()) {
        
        if (T.self == VNDetectFaceRectanglesRequest.self) {
            
            self._detectFaceRectanglesRequest(dispatchQueue: dispatchQueue, options: options) { detectResult in
                switch detectResult {
                case .failure(let error): result(.failure(error))
                case .success(let request):
                    let results = request.results as? [VNFaceObservation]
                    result(.success(results))
                }
            }
        }
        
        if (T.self == VNDetectFaceLandmarksRequest.self) {
            
            self._detectFaceLandmarksRequest(dispatchQueue: dispatchQueue, options: options) { detectResult in
                switch detectResult {
                case .failure(let error): result(.failure(error))
                case .success(let request):
                    let results = request.results as? [VNFaceObservation]
                    result(.success(results))
                }
            }
        }
    }
    
    /// [取得人臉辨識的結果](https://medium.com/@zhgchgli/vision-初探-app-頭像上傳-自動識別人臉裁圖-swift-9a9aa892f9a9)
    /// - Parameters:
    ///   - type: T: VNImageBasedRequest
    ///   - dispatchQueue: [DispatchQueue](https://juejin.cn/post/6844903504469819399)
    ///   - options: [VNImageOption : Any](https://www.jianshu.com/p/59b43dbe4fbd)
    ///   - result: Result<VNRequest, Error>
    func _detectFaceRequest<T: VNImageBasedRequest>(for type: T.Type, dispatchQueue: DispatchQueue = .global(), options: [VNImageOption : Any] = [:], result: @escaping (Result<VNRequest, Error>) -> ()) {
        
        guard let ciImage = self._ciImage() else { result(.failure(Constant.MyError.notImage)); return }
        
        let faceRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: options)
        var faceRequest: VNImageBasedRequest?
        
        if (T.self == VNDetectFaceRectanglesRequest.self) {
            
            faceRequest = VNDetectFaceRectanglesRequest { request, error in
                if let error = error { result(.failure(error)); return }
                result(.success(request))
            }
        }
        
        if (T.self == VNDetectFaceLandmarksRequest.self) {
            
            faceRequest = VNDetectFaceLandmarksRequest { request, error in
                if let error = error { result(.failure(error)); return }
                result(.success(request))
            }
        }

        dispatchQueue.async {
            
            guard let faceRequest = faceRequest as? T else { result(.failure(Constant.MyError.notTypeCasting)); return }
            
            do {
                try faceRequestHandler.perform([faceRequest])
            } catch {
                result(.failure(error))
            }
        }
    }
}

// MARK: - UIImageView (class function)
extension UIImageView {
    
    /// [辨識圖片上人臉特徵點的位置](https://www.jianshu.com/p/83aa3983ac76)
    /// - Parameters:
    ///   - dispatchQueue: DispatchQueue
    ///   - landmarkTypes: [Constant.FaceLandmarkRegion]
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<[Constant.FeaturePoints]?, Error>
    func _detectFaceLandmarksBox(dispatchQueue: DispatchQueue = .global(), landmarkTypes: [Constant.FaceLandmarkRegion], options: [VNImageOption : Any] = [:], result: @escaping (Result<[Constant.FeaturePoints]?, Error>) -> ()) {
        
        guard let innerImage = self.image else { result(.failure(Constant.MyError.notImage)); return }
        
        innerImage._detectFaceLandmarksResult(dispatchQueue: dispatchQueue, options: options) { detectResult in
            
            switch detectResult {
            case .failure(let error): result(.failure(error))
            case .success(let detectResults):
                
                guard let detectResults = detectResults else { return result(.success(nil)) }
                
                DispatchQueue.main.async {
                    let featurePoints = detectResults.compactMap { $0._featurePoints(mirrorTo: self, landmarkTypes: landmarkTypes) }
                    result(.success(featurePoints))
                }
            }
        }
    }
    
    /// [取得內部圖片的大小](https://stackoverflow.com/questions/4711615/how-to-get-the-displayed-image-frame-from-uiimageview)
    /// - Returns: CGRect?
    func _imageFrameWithAspectRatio() -> CGRect? {
        guard let image = self.image else { return nil }
        return AVMakeRect(aspectRatio: image.size, insideRect: self.bounds)
    }
}

// MARK: - AVCaptureDevice (static function)
extension AVCaptureDevice {
    
    /// 取得預設影音裝置 (NSCameraUsageDescription / NSMicrophoneUsageDescription)
    static func _default(for type: AVMediaType) -> AVCaptureDevice? { return AVCaptureDevice.default(for: type) }
}

// MARK: - AVCaptureDevice (class function)
extension AVCaptureDevice {
        
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
    
    /// [設定輸出的解析度](https://www.itread01.com/hklecii.html)
    /// - Parameter sessionPreset: [AVCaptureSession.Preset](https://developer.apple.com/documentation/avfoundation/avcapturesession/1389696-sessionpreset)
    func _canSetVideoResolution(_ sessionPreset: AVCaptureSession.Preset = .hd1920x1080) -> Bool {
        
        guard self.canSetSessionPreset(sessionPreset) else { return false }
        
        self.sessionPreset = sessionPreset
        return true
    }
}

// MARK: - AVCaptureVideoDataOutput (class function)
extension AVCaptureVideoDataOutput {
    
    /// [設定影片的輸出方向](https://www.codenong.com/3823461/)
    /// - Parameter orientation: [AVCaptureVideoOrientation](https://medium.com/onfido-tech/live-face-tracking-on-ios-using-vision-framework-adf8a1799233)
    /// - Returns: Bool
    func _videoOrientationSetting(_ orientation: AVCaptureVideoOrientation = .portrait) -> Bool {
        
        guard let connection = self.connection(with: .video),
              connection.isVideoOrientationSupported
        else {
            return false
        }

        connection.videoOrientation = orientation
        return true
    }
}

// MARK: - AVCaptureVideoPreviewLayer (class function)
extension AVCaptureVideoPreviewLayer {
    
    /// [由captureOutput(_:didOutput:from:)取得的CMSampleBuffer => 測檢人臉在PreviewLayer上的位置](https://stackoverflow.com/questions/44698368/layerrectconvertedfrommetadataoutputrect-issue)
    /// - Parameters:
    ///   - cmSampleBuffer: [CMSampleBuffer](https://medium.com/onfido-tech/live-face-tracking-on-ios-using-vision-framework-adf8a1799233)
    ///   - orientation: [UIImage.Orientation](https://machinethink.net/blog/bounding-boxes/)
    ///   - result: [Result<[CGRect]?, Error>](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate/1385775-captureoutput)
    func _detectFaceLandmarksBox(with cmSampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation = .leftMirrored, result: @escaping (Result<[CGRect]?, Error>) -> ()) {
        
        guard let bufferImage = cmSampleBuffer._uiImage(scale: UIScreen.main.scale, orientation: orientation),
              let normalizedImage = bufferImage._normalized()
        else {
            result(.failure(Constant.MyError.notImage)); return
        }
        
        normalizedImage._detectFaceLandmarksResult { _result in
            
            switch _result {
            case .failure(let error): result(.failure(error))
            case .success(let faces):
                
                guard let faces = faces, !faces.isEmpty else { result(.success(nil)); return }
                
                let faceBoundingBoxOnScreens = faces.map { self.layerRectConverted(fromMetadataOutputRect: $0.boundingBox) }
                result(.success(faceBoundingBoxOnScreens))
            }
        }
    }
}

// MARK: - VNFaceObservation (class function)
extension VNFaceObservation {
    
    /// [將取得的比例大小 => 畫面上的大小 -> .scaleToFill / .scaleAspectFit](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-cgaffinetransform-控制元件縮放-位移-旋轉的三種方法-dca1abbf9590)
    /// - Parameter imageView: UIImageView
    /// - Returns: CGRect
    func _convertRatio(mirrorTo imageView: UIImageView) -> CGRect? {
        
        var frame: CGRect?
        
        switch imageView.contentMode {
        case .scaleToFill: frame = imageView.frame
        case .scaleAspectFit: frame = imageView._imageFrameWithAspectRatio()
        default: break
        }
        
        guard let frame = frame else { return nil }
        return self._convertRatio(mirrorTo: frame)
    }
    
    /// [將取得的比例大小 => 位置](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/83-利用-cgaffinetransform-縮放-位移和旋轉-e061df9ed672)
    /// - Parameter frame: [CGRect](https://medium.com/彼得潘的-swift-ios-app-開發教室/作業-52-使用-swiftui-預覽-uibezierpath-畫出喜歡角落的貓咪-ed4042a23303)
    /// - Returns: CGRect
    func _convertRatio(mirrorTo frame: CGRect) -> CGRect {
        return self.boundingBox._convertRatio(scaleX: 1.0, scaleY: -1.0, to: frame)
    }
    
    /// [轉換圖片上人臉關鍵點的位置 => 滿版](https://www.jianshu.com/p/59b43dbe4fbd)
    /// - Parameters:
    ///   - frame: 對應要顯示的UIView大小
    ///   - landmarkTypes: 人臉特徵點的類型 (左眼 / 右眼 / …)
    /// - Returns: Constant.FeaturePoints
    func _featurePoints(mirrorTo frame: CGRect, landmarkTypes: [Constant.FaceLandmarkRegion]) -> Constant.FeaturePoints {
        
        let faceBox = self._convertRatio(mirrorTo: frame)
        var faceRegion: Constant.FeaturePoints = (nil, [])
        
        landmarkTypes.forEach { region in
            
            let regionClass = region.toClass(with: self)
            let points = regionClass?._convertPoints(mirrorTo: frame, detectResult: self)
            
            faceRegion.landmarks.append(points)
        }
        
        faceRegion.box = faceBox
        return faceRegion
    }
    
    /// [將取得的比例大小 => 畫面上的大小 -> .scaleToFill / .scaleAspectFit](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-cgaffinetransform-控制元件縮放-位移-旋轉的三種方法-dca1abbf9590)
    /// - Parameters:
    ///   - imageView: UIImageView
    ///   - landmarkTypes: [Constant.FaceLandmarkRegion]
    /// - Returns: Constant.FeaturePoints?
    func _featurePoints(mirrorTo imageView: UIImageView, landmarkTypes: [Constant.FaceLandmarkRegion]) -> Constant.FeaturePoints? {
        
        var frame: CGRect?
        
        switch imageView.contentMode {
        case .scaleToFill: frame = imageView.frame
        case .scaleAspectFit: frame = imageView._imageFrameWithAspectRatio()
        default: break
        }
        
        guard let frame = frame else { return nil }
        return self._featurePoints(mirrorTo: frame, landmarkTypes: landmarkTypes)
    }
}

// MARK: - VNFaceLandmarkRegion2D (class function)
extension VNFaceLandmarkRegion2D {
    
    /// [轉換檢測出來臉上特徵點的位置 -> .scaleToFill / .scaleAspectFit](https://stackoverflow.com/questions/4711615/how-to-get-the-displayed-image-frame-from-uiimageview)
    /// - Parameters:
    ///   - frame: CGRect
    ///   - detectResult: VNFaceObservation
    /// - Returns: [CGPoint]
    func _convertPoints(mirrorTo imageView: UIImageView, detectResult: VNFaceObservation) -> [CGPoint]? {
        
        var frame: CGRect?
        
        switch imageView.contentMode {
        case .scaleToFill: frame = imageView.frame
        case .scaleAspectFit: frame = imageView._imageFrameWithAspectRatio()
        default: frame = nil
        }
        
        guard let frame = frame else { return nil }
        return self._convertPoints(mirrorTo: frame, detectResult: detectResult)
    }
    
    /// [轉換檢測出來特徵點的位置](https://medium.com/msapps-development/face-recognition-ios-fadfecb99b15)
    /// - Parameters:
    ///   - frame: CGRect
    ///   - detectResult: VNFaceObservation
    /// - Returns: [CGPoint]
    func _convertPoints(mirrorTo frame: CGRect, detectResult: VNFaceObservation) -> [CGPoint] {
        
        let faceBox = detectResult._convertRatio(mirrorTo: frame)
        
        let mirrorPoints = self.normalizedPoints.map({ normalizedPoint -> CGPoint in
            
            let px = faceBox.minX + (normalizedPoint.x * faceBox.width)
            let py = faceBox.minY + (1.0 - normalizedPoint.y) * faceBox.height

            return CGPoint(x: px, y: py)
        })
        
        return mirrorPoints
    }
}

// MARK: - CMSampleBuffer (class function)
extension CMSampleBuffer {
    
    /// [CMSampleBuffer => CIImage](https://rethunk.medium.com/cmsamplebuffer-to-uiimage-in-swift-5bf96d393d5e)
    /// - [captureOutput(_:didOutput:from:)](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate/1385775-captureoutput)
    /// - Returns: [CIImage?](https://developer.apple.com/documentation/coremedia/cmsamplebuffer-u71)
    func _ciImage() -> CIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        return CIImage(cvImageBuffer: imageBuffer)
    }
    
    /// [CMSampleBuffer => UIImage](https://www.itread01.com/content/1548295221.html)
    /// - Parameters:
    ///   - scale: [CGFloat](https://blog.csdn.net/iTaacy/article/details/69258116)
    ///   - orientation: [UIImage.Orientation](https://developer.apple.com/documentation/uikit/uiimage/1624147-cgimage)
    /// - Returns: [UIImage?](https://www.jianshu.com/p/b0e5f2944b3d)
    func _uiImage(scale: CGFloat = 1.0, orientation: UIImage.Orientation = .right) -> UIImage? {
        return self._ciImage()?._createUIImage(scale: scale, orientation: orientation)
    }
}
