//
//  AppDelegate.swift
//  HelloMediaPlayer
//
//  Created by William.Weng on 2021/5/4.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myDelegate: FilePathDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // [https://www.jianshu.com/p/978d38533c5c](info.plist => CFBundleDocumentTypes)
        myDelegate?.updateFilePath(url: url)
        return true
    }
}

