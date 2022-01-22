//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2022/1/22.

import UIKit
import AVFoundation
import AVKit
import WWPrint

final class ViewController: UIViewController {

    @IBOutlet weak var myImageView: UIImageView!
    
    private let captureSession = AVCaptureSession()
    private let captureVideoDataOutput = AVCaptureVideoDataOutput()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var tempLayers: [CALayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func detectFaceWithImage(_ sender: UIBarButtonItem) {
        faceLandmarksBoxing(with: myImageView, landmarkTypes: [.leftEye, .nose])
    }
    
    @IBAction func detectFaceWithVideo(_ sender: UIBarButtonItem) {
        
        guard cameraPreview(session: captureSession) else { return }
        
        captureVideoDataOutput.setSampleBufferDelegate(self, queue: .global())
        captureSession.startRunning()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        faceRectanglesBoxing(with: sampleBuffer)
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 打開相機預覽 / NSCameraUsageDescription
    func cameraPreview(session: AVCaptureSession) -> Bool {
        
        guard let device = AVCaptureDevice._default(for: .video),
              let input = try? device._captureInput().get(),
              let _previewLayer = Optional.some(session._previewLayer(with: view.bounds, videoGravity: .resize)),
              session._canAddInput(input),
              session._canAddOutput(captureVideoDataOutput)
        else {
            return false
        }
        
        previewLayer = _previewLayer
        view.layer.addSublayer(_previewLayer)
        
        return true
    }
    
    /// 影片人臉標示
    func faceRectanglesBoxing(with buffer: CMSampleBuffer) {
        
        guard let image = buffer._uiImage()?._normalized() else { return }
        
        DispatchQueue.main.async {
            
            self.tempLayers._removeFromSuperlayer()
            self.tempLayers.removeAll()
            
            image._detectFaceRectanglesBox(mirrorTo: self.myImageView.frame) { result in
                
                switch result {
                case .failure(let error): wwPrint(error)
                case .success(let frames):
                                        
                    guard let frames = frames else { return }
                    
                    frames.forEach { frame in
                        let rectLayer = CALayer()._frame(frame)._borderColor(.red)._borderWidth(2.0)._backgroundColor(.yellow)
                        self.tempLayers.append(rectLayer)
                        self.view.layer.addSublayer(rectLayer)
                    }
                }
            }
        }
    }
    
    /// 圖片人臉標示
    func faceLandmarksBoxing(with imageView: UIImageView, landmarkTypes: [Constant.FaceLandmarkRegion]) {
        
        imageView._detectFaceLandmarksBox(landmarkTypes: landmarkTypes) { result in
            
            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let faceRegions):
                
                guard let faceRegions = faceRegions else { return }
                
                faceRegions.forEach { regions in
                    
                    if let frame = regions.box {
                        let layer = CALayer()._frame(frame)._borderColor(.red)._borderWidth(1.0)
                        self.view.layer.addSublayer(layer)
                    }
                                            
                    regions.landmarks.forEach { points in
                        
                        guard let points = points else { return }
                        
                        points.forEach { point in
                            let frame = CGRect(origin: point, size: CGSize(width: 3.0, height: 3.0))
                            let layer = CALayer()._frame(frame)._borderColor(.green)._borderWidth(1.0)
                            self.view.layer.addSublayer(layer)
                        }
                    }
                }
            }
        }
    }
}
