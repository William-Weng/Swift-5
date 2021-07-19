//
//  ViewController.swift
//  NFC_CheckIn
//
//  Created by William.Weng on 2020/2/17.
//  Copyright © 2020 William.Weng. All rights reserved.
//
/// [【WWDC19】Core NFC で FeliCa(Suica) を読み取るサンプル【iOS 13 以降】](https://qiita.com/treastrain/items/23d343d2c215ab53ecbf)
/// [將 Push Notification Data 型別的 device token 變成 String](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/將-push-notification-data-型別的-device-token-變成-string-a89e08736bdf)
/// [ISO/IEC 14443](https://zh.wikipedia.org/wiki/ISO/IEC_14443)
/// [ISO 14443 A/B非接觸式智慧卡應用](https://www.digitimes.com.tw/iot/article.asp?cat=130&id=0000129338_g8u2ors04xyepe78wmr08)

import UIKit
import CoreNFC
import Firebase
import PKHUD
import SafariServices

final class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nfcTagIdentityLabel: UILabel!

    private let minimumLength = 3
    private let hudDelay: TimeInterval = 1.0

    private let miFareTag = "miFareTag"
    private let pollingOption: NFCTagReaderSession.PollingOption = .iso14443
    private let alertMessage = "請使用NFC做報到的動作"

    private var tagSession: NFCTagReaderSession?
    
    private lazy var uuid: String = { identityMaker() }()
    private lazy var username: String? = { usernameMaker() }()
    private lazy var meeting: String? = { mettingMaker() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }

    /// 彈出NFC Reader
    @IBAction func nfcTest(_ sender: UIBarButtonItem) {
        dismissKeyboard()
        if checkNameLength(min: minimumLength) == true { showNFC(option: pollingOption) }
    }
    
    /// 開啟網頁
    @IBAction func infoLink(_ sender: UIBarButtonItem) {
        
        dismissKeyboard()
        
        guard let meeting = mettingMaker() else { HUD.flash(.error, delay: hudDelay); return }
        
        meetingInfoURL(meeting: meeting) { (url) in
            guard let url = url else { return }
            wwPrint(url)
            self.gotoURL(url)
        }
    }

    /// 會議CheckIn列表
    @IBAction func checkinLink(_ sender: UIBarButtonItem) {
        
        dismissKeyboard()
        
        guard let meeting = mettingMaker() else { HUD.flash(.error, delay: hudDelay); return }
        
        let url = webAPIURLMaker(meeting: meeting)
        self.gotoURL(url)
    }
}

// MARK: - SFSafariViewControllerDelegate
extension ViewController: SFSafariViewControllerDelegate {

    /// 以網頁顯示
    private func gotoURL(_ urlString: String?) {

        guard let urlString = urlString,
              let urlEncodedString = Utility.urlEncoded(urlString),
              let url = URL(string: urlEncodedString)
        else {
            HUD.flash(.error, delay: hudDelay); return
        }
        
        let safariViewController = SFSafariViewController(url: url)

        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }
}

// MARK: - NFCTagReaderSessionDelegate
extension ViewController: NFCTagReaderSessionDelegate {
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        wwPrint("tagReaderSessionDidBecomeActive")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        wwPrint(error.localizedDescription)
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {

        defer { session.invalidate() }
        
        guard let tag = tags.first else { return }

        switch tag {
        case .miFare(let miFareTag):
            
            DispatchQueue.main.async {
                
                HUD.flash(.progress)
                
                self.meetingKey(miFareTag: miFareTag) { (meetingKey) in
                    guard let meetingKey = meetingKey else { HUD.flash(.error, delay: self.hudDelay); return }
                    self.checkIn(meeting: meetingKey); return
                }
            }

        case .iso15693(_): print("iso15693")
        case .iso7816(_): print("iso7816")
        case .feliCa(_): print("feliCa")
        @unknown default: print("unknown")
        }
    }
}

// MARK: - 主工具
extension ViewController {
        
    /// 初始化設定
    private func initSetting() {
        
        guard let username = username else { return }
        
        nameTextField.text = username
        showNFC(option: pollingOption)
    }
    
    /// 名字要大於3碼
    private func checkNameLength(min: Int) -> Bool {
        
        guard let username = self.nameTextField.text,
              self.checkname(username, minimum: min)
        else {
            let promptAlert = Utility.promptAlertController(withTitle: "錯誤", message: "姓名長度不足3碼") {}
            self.present(promptAlert, animated: true, completion: nil)
            return false
        }

        self.userInfoWriter(value: username, key: .username)
        
        return true
    }
    
    /// 報到
    private func checkIn(meeting: String) {
        
        guard let username = self.nameTextField.text,
              self.checkname(username, minimum: self.minimumLength)
        else {
            let promptAlert = Utility.promptAlertController(withTitle: "錯誤", message: "姓名長度不足3碼") {}
            self.present(promptAlert, animated: true, completion: nil)
            return
        }

        updateValue(meeting: meeting, uuid: self.uuid, name: username)
    }

    /// 顯示NFC視窗
    private func showNFC(option: NFCTagReaderSession.PollingOption) {
        tagSession = NFCTagReaderSession(pollingOption: option, delegate: self)
        tagSession?.alertMessage = alertMessage
        tagSession?.begin()
    }
}

// MARK: - API
extension ViewController {
    
    /// 取得會議的identiy
    private func meetingKey(miFareTag: NFCMiFareTag, result: @escaping (String?) -> Void) {
        
        let identifier = self.dataToHexString(miFareTag.identifier)
        let reference = Database.database().reference().child(DatabasePath.nfcTag.rawValue).child(identifier)
                        
        nfcTagIdentityLabel.text = identifier
        
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
                        
            guard let value = snapshot.value as? [String: String],
                  let meetingKey = value["key"]
            else {
                result(nil); return
            }
            
            result(meetingKey)
        }, withCancel: { (error) in
            wwPrint(error)
            result(nil)
        })
    }

    /// 報到 (Fireabase)
    private func updateValue(meeting: String, uuid: String, name: String) {

        let reference = Database.database().reference().child(DatabasePath.checkIn.rawValue).child(meeting).child(uuid)
        let parameters = ["name": name.trimmingCharacters(in: .whitespacesAndNewlines), "time": Date().description]

        reference.updateChildValues(parameters) { (error, reference) in
            
            if let _ = error { HUD.flash(.error, delay: self.hudDelay); return }
            
            DispatchQueue.main.async {
                self.userInfoWriter(value: meeting, key: .metting)
                HUD.flash(.success, delay: self.hudDelay)
            }
        }
    }

    /// 取得會議的url
    private func meetingInfoURL(meeting: String, result: @escaping (String?) -> Void) {
        
        let reference = Database.database().reference().child(DatabasePath.meetingInformation.rawValue).child(meeting)

        reference.observeSingleEvent(of: .value, with: { (snapshot) in
                        
            guard let value = snapshot.value as? [String: String],
                  let url = value["url"]
            else {
                result(nil); return
            }
            
            result(url)
        }, withCancel: { (error) in
            wwPrint(error)
            result(nil)
        })
    }

    /// 網頁的API URL (報到列表)
    private func webAPIURLMaker(meeting: String) -> String {
        return "https://nfc-checkin.firebaseapp.com?path=\(meeting)"
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 產生UUID / 記錄
    private func identityMaker() -> String {

        guard let identity = userInfoReader(key: .identity) else {
            let uuid = UUID().uuidString
            userInfoWriter(value: uuid, key: .identity)
            return uuid
        }

        return identity
    }
    
    /// 產生UserName
    private func usernameMaker() -> String? {
        guard let username = userInfoReader(key: .username) else { return nil }
        return username
    }
    
    /// 產生Metting
    private func mettingMaker() -> String? {
        guard let metting = userInfoReader(key: .metting) else { return nil }
        return metting
    }

    /// 記錄UserDefaults的值
    private func userInfoWriter(value: String, key: UserInfo) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key.rawValue)
    }

    /// 讀取UserDefaults的值
    private func userInfoReader(key: UserInfo) -> String? {
        
        guard let userDefaults = Optional.some(UserDefaults.standard),
              let value = userDefaults.value(forKey: key.rawValue) as? String
        else {
            return nil
        }

        return value
    }

    /// 驗查姓名的最小字數 (去除頭尾空白)
    private func checkname(_ name: String, minimum: Int) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmedName.count < minimum) ? false : true
    }

    /// Data => 0x0413dc22d52481
    private func dataToHexString(_ data: Data) -> String {
        let hexString = data.reduce("") { return $0 + String(format: "%02x", $1) }
        return "0x" + hexString
    }

    /// 關掉鍵盤
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}
