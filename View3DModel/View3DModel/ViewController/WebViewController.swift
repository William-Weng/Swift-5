//
//  WebViewController.swift
//  View3DModel
//
//  Created by William-Weng on 2019/2/20.
//  Copyright © 2019年 William-Weng. All rights reserved.
//
/// [網頁顯示3D模型 - Web](https://codertw.com/前端開發/53118/)
/// [3D模型免安裝直接看，免費三大好站報給你知！](https://inplus.tw/archives/773)

import UIKit
import WebKit

// MARK: - WebViewController
class WebViewController: UIViewController {
    
    /// 測試3D模型的網站名稱
    enum Model3DType {
        case _P3D_
        case _Sketchfab_
        case _3DPunk_
        case _ThreeJS_
    }
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        loadWebView(with: httpUrlMaker(with: ._3DPunk_))
    }
    
    deinit {
        print("WebViewController deinit")
    }
}

// MARK: - 小工具
extension WebViewController {
    
    /// WebView的切始設定
    private func initWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.isHidden = true
        
        view = webView
    }
    
    /// 讀取網址
    private func loadWebView(with url: String?) {
        
        guard let url = url,
              let myURL = URL(string: url)
        else {
            return
        }
        
        webView.isHidden = false
        webView.load(URLRequest(url: myURL))
    }
    
    /// 各3D網頁的測試網址
    private func httpUrlMaker(with type: Model3DType) -> String {
        
        var httpURL = String()
        
        switch type {
        case ._3DPunk_: httpURL = "https://skfb.ly/6GVUH"
        case ._P3D_: httpURL = "https://editor.3dpunk.com/editor2?mode=1&oid=osZS2101336ZjLkl&width=640&height=480&sharecode=null"
        case ._Sketchfab_: httpURL = "https://skfb.ly/6GVUH"
        case ._ThreeJS_: httpURL = "http://one-pieces.me/threejs-practice/one-piece-top-war/index.html"
        }
        
        return httpURL
    }
}
