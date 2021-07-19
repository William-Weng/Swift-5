//
//  ViewController.swift
//  URLSessionDemo
//
//  Created by William.Weng on 2020/8/5.
//  Copyright © 2020 William.W
/// [URLSession 教學（swift 3, iOS）- part 1](https://medium.com/@jerrywang0420/urlsession-教學-swift-3-ios-part-1-a1029fc9c427)
/// [URLSession 教學（swift 3, iOS）- part 2](https://medium.com/@jerrywang0420/urlsession-教學-swift-3-ios-part-2-a17b2d4cc056)
/// [URLSession 教學（swift 3, iOS）- part 3](https://medium.com/@jerrywang0420/urlsession-教學-swift-3-ios-part-3-34699564fb12)
/// [Swift建立URL. 在Swift，我之前也是一直都直接用這樣建立一個URL:](https://medium.com/@dafu1231/swift建立url-dec8a26d794e)
/// [重新認識HTTP請求方法](https://openhome.cc/Gossip/Programmer/HttpMethod.html)
/// [NSString簡單細說（二十一）—— 字符串與編碼 - 簡書](https://www.jianshu.com/p/bfbcdfa65360)
/// [【POST】請求頭 Content-type](https://medium.com/@des75421/post-請求頭-content-type-82b93f9230f7)
/// [Content-Type - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type)
/// [RFC1341(MIME) : 7 The Multipart content type](https://www.w3.org/Protocols/rfc1341/7_2_Multipart.html)
/// [Content-Disposition - HTTP | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Content-Disposition)
/// [HTTP/1.1 - 訊息格式 (Message Format) - NotFalse 技術客](https://notfalse.net/39/http-message-format)
/// [以 C Socket 實作 HTTP Client - NotFalse 技術客](https://notfalse.net/47/c-socket-http-client)
/// [HTTP 狀態碼 (Status Codes) - NotFalse 技術客](https://notfalse.net/48/http-status-codes)
/// [HTTP GET vs POST - NotFalse 技術客](https://notfalse.net/44/http-get-vs-post)

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var myTextField: UITextView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myProgressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    @IBAction func testURLRequest(_ sender: UIBarButtonItem) {

        let urlString = "https://httpbin.org/post"
        let parameters = ["name" : "中文也會通"]
        let headers = ["header" : "真的喲"]
        let jsonData = Utility.shared.jsonSerialization(with: ["jsonData": "DEMO"])
        let httpBodyInfomation: UtilityWeb.HttpBodyInfomation = (.json, jsonData)

        UtilityWeb.shared.requestJSON(with: .POST, urlString: urlString, parameters: parameters, headers: headers, httpBodyInfomation: httpBodyInfomation) { (result) in

            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let info):
                if let dictionary = info.value as? [String: Any] { DispatchQueue.main.async { self.myTextField.text = dictionary.description }}
                if let response = info.response as? HTTPURLResponse { wwPrint(response) }
            }
        }
    }

    @IBAction func testURLDownload(_ sender: UIBarButtonItem) {
        
        let imageURLString = "https://www.appcoda.com.tw/wp-content/uploads/2020/03/preface-cover-1-787x1024.png"
        
        UtilityWeb.shared.downloadRequest(urlString: imageURLString, downloadBytes: { (bytes) in
            
            let progress = Float(bytes.written) / Float(bytes.total)
            DispatchQueue.main.async { self.myProgressView.progress = progress }
            
        }, finish: { (result) in
            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let data): DispatchQueue.main.async { self.myImageView.image = UIImage(data: data) }
            }
        })
    }

    @IBAction func testURLUpload(_ sender: UIBarButtonItem) {
        
        let urlString = "http://172.16.20.29:3000/api/photo"
        let formInputField = "Picture"
        
        let imageData = #imageLiteral(resourceName: "marker").pngData()
        let fileInfos: [UtilityWeb.UploadFileInfomation] = [
            (name: "QOO.png", data: imageData!),
            (name: "T_T.png", data: imageData!),
        ]

        UtilityWeb.shared.uploadRequest(with: .POST, urlString: urlString, mimeType: .png, field: formInputField, fileInfos: fileInfos) { (result) in
            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let info): wwPrint(info)
            }
        }
    }
}
