//
//  OnlineDictionaryViewController.swift
//  MyEnglish
//
//  Created by Yu-Bin Weng on 2021/1/10.
//

import UIKit
import WebKit
import PKHUD

final class OnlineDictionaryViewController: UIViewController {
        
    var word = ""
    var voiceCode: Utility.VoiceCode = .english

    override func viewDidLoad() {
        super.viewDidLoad()
        title = word
        initSetting(with: word)
    }
}

// MARK: - WKNavigationDelegate
extension OnlineDictionaryViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) { HUD.show(.progress) }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) { HUD.flash(.success) }
}

// MARK: - WKUIDelegate
extension OnlineDictionaryViewController: WKUIDelegate {}

extension OnlineDictionaryViewController {
    
    /// 初始化WebView
    private func initSetting(with word: String) {
                
        guard let webView = Optional.some(WKWebView._build(delegate: self, frame: view.frame)),
              let urlString = Optional.some(voiceCode.dictionaryURL(with: word)),
              let url = URL._standardization(string: urlString),
              let request = Optional.some(URLRequest(url: url))
        else {
            return
        }
        
        view = webView
        webView.load(request)
    }
}
