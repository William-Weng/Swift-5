//
//  ViewController.swift
//  View3DModel
//
//  Created by William-Weng on 2019/2/19.
//  Copyright © 2019年 William-Weng. All rights reserved.
//
/// [iOS - SceneKit顯示與交互3D建模（一）](https://www.jianshu.com/p/df7514a6cb91)
/// [SceneKit | 加載 3D模型(obj/scn/dae)到你的AR項目中](https://www.jianshu.com/p/15101aa0eefe)
/// [SceneKit開發關於加載obj格式文件的處理](https://www.jianshu.com/p/6a761a834ab9)

import UIKit
import SceneKit
import AVKit

// MARK: - SceneDelegate
protocol SceneDelegate: AnyObject {
    
    /// 更新場景
    func updataScene(_ scene: SCNScene?)
}

// MARK: - UINavigationBar (class function)
extension UINavigationBar {
    
    /// 透明背景 (透明底線)
    func _transparent() {
        
        let transparentBackground = UIImage()
        
        self.isTranslucent = true
        self.setBackgroundImage(transparentBackground, for: .default)
        self.shadowImage = transparentBackground
    }
}

// MARK: - ViewController
class ViewController: UIViewController {

    @IBOutlet weak var scnView: SCNView!
    
    let captureSession = AVCaptureSession()
    let captureOutput = (photo: AVCapturePhotoOutput(), movie: AVCaptureMovieFileOutput(), video: AVCaptureVideoDataOutput())
    var currentDevice: (video: AVCaptureDevice?, audio: AVCaptureDevice?) = (nil, nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSetting2()
        
        let scene = modelScene(with: "Minion.scn")
        let cameraNode = cameraNodeMaker()
        let lightNode = lightNodeMaker(with: .ambient, lightColor: .gray)
        
        scene?.rootNode.addChildNode(cameraNode)
        scene?.rootNode.addChildNode(lightNode)

        scnView.scene = scene
        
        navigationController?.navigationBar._transparent()
        view.bringSubviewToFront(scnView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier,
              identifier == "FileViewSegue",
              let fileViewController = segue.destination as? FileViewController
        else {
            return
        }
        
        fileViewController.myDelegate = self
    }
    
    deinit {
        print("ViewController deinit")
    }
    
    /// 初始化設定 (取得一開始的camera預覽畫面)
    private func initSetting() {

    }
}

// MARK: - SceneDelegate
extension ViewController: SceneDelegate {
    
    func updataScene(_ scene: SCNScene?) {
        scene?.rootNode.geometry?.firstMaterial?.lightingModel = .lambert
        scnView.scene = scene
    }
}

// MARK: - 小工具
extension ViewController {

    /// 取得場景
    private func modelScene(with filename: String) -> SCNScene? {
        
        let scene = SCNScene(named: "Model.scnassets/\(filename)")

        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true

        return scene
    }
    
    /// 相機節點
    private func cameraNodeMaker() -> SCNNode {
        
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 5, 15);
        
        return cameraNode
    }
    
    /// 燈光節點
    private func lightNodeMaker(with type: SCNLight.LightType, lightColor: UIColor) -> SCNNode {
        
        let lightNode = SCNNode()
    
        lightNode.light = SCNLight()
        lightNode.light?.type = type
        lightNode.position = SCNVector3Make(10, 10, 10)
        lightNode.light?.color = lightColor.cgColor

        return lightNode
    }
}

extension ViewController {
    
    /// 初始化設定 (取得一開始的camera預覽畫面)
    private func initSetting2() {
        
        guard let videoDevice = currentDeviceMaker(type: .video),
              canAddDeviceSessionInput(device: videoDevice)
        else {
            return
        }
        
        currentDevice.video = videoDevice
        showPreviewLayer(for: captureSession)
    }
    
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
    
    /// 加上Session的DeviceInput
    private func canAddDeviceSessionInput(device: AVCaptureDevice) -> Bool {
        
        guard let deviceInput = try? captureCurrentDeviceInput(device: device),
              canAddDeviceInputForSession(deviceInput)
        else {
            return false
        }
        
        return true
    }
    
    /// 顯示PreviewLayer
    private func showPreviewLayer(for session: AVCaptureSession) {
        
        let previewLayer = previewLayerMaker(for: session)

        view.layer.insertSublayer(previewLayer, below: view.layer)
        session.startRunning()
    }
    
    /// 產生、設定PreviewLayer
    private func previewLayerMaker(for session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }
}
