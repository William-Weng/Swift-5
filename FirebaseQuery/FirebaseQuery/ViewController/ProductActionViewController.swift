//
//  _ProductMainViewController.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/13.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import KRProgressHUD
import FirebaseStorage
import Kingfisher

// MARK: - 加入新書
class ProductActionViewController: UIViewController {
    
    @IBOutlet var isbnTextField: MyTextField!
    @IBOutlet var titleTextField: MyTextField!
    @IBOutlet var countTextField: MyTextField!
    @IBOutlet var productImageView: UIImageView!
    
    let imageType: FIRStorage.ImageType = .jpeg
    
    var navigationItemTitle: String = String()
    var tabBarType: TabBarType = .cart
    var originalCount: Int?
    
    lazy var readerViewController: QRCodeReaderViewController = { qrCodeReaderViewControllerMaker(forTypes: [.ean13]) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSetting()
        initSettingWithType(tabBarType)
        navigationItemTitleSetting(navigationItemTitle)
    }

    @IBAction func productActoin(_ sender: UIBarButtonItem) {
        productActionRunning(sender, forType: tabBarType)
    }
    
    @IBAction func scanBarcode(_ sender: UIBarButtonItem) {
        presentReaderViewController()
    }
    
    /// 拍攝照片
    @IBAction func photograph(_ sender: UIButton) {
        photographAction(forType: tabBarType)
    }
    
    /// 取消鍵盤
    @objc private func dismissKeyboard(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProductActionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let originalImage = info[.originalImage] as? UIImage
        dismiss(animated: true) { self.updateWebImage(originalImage) }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - QRCodeReaderViewControllerDelegate
extension ProductActionViewController: QRCodeReaderViewControllerDelegate {
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        stopCodeReaderScan(reader)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        stopCodeReaderScan(reader)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("切換鏡頭: \(newCaptureDevice.device.localizedName)")
    }
    
    /// 停止掃瞄
    private func stopCodeReaderScan(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    // 彈出掃Code的視窗
    private func presentReaderViewController() {
        
        readerViewController.delegate = self
        readerViewController.modalPresentationStyle = .formSheet

        readerViewController.completionBlock = { (result: QRCodeReaderResult?) in
            self.scanAction(withResult: result, forType: self.tabBarType)
        }
        
        present(readerViewController, animated: true, completion: nil)
    }
    
    /// 掃完條碼之後要做的事
    private func scanAction(withResult result: QRCodeReaderResult?, forType type: TabBarType) {
        
        guard let barCode = result?.value else { return }
        
        switch (type) {
        case .cart:
            isbnTextField.text = barCode
            downloadImageWithISBN(barCode, type: imageType)
        case .plus, .minus, .fix:
            searchBookInfomation(withBarCode: Int(barCode), forType: type)
            downloadImageWithISBN(barCode, type: imageType)
        case .stock: break
        }
    }
    
    /// 執行對應該選擇的動作 (CRUD)
    private func productActionRunning(_ sender: UIBarButtonItem, forType type: TabBarType) {
        
        switch (type) {
        case .cart, .fix: appendBook(sender)
        case .plus, .minus: updateBookCount(countTextField.text, barCode: isbnTextField.text, type: tabBarType)
        case .stock: break
        }
    }
    
    /// 產生掃描Barcode的ViewController
    private func qrCodeReaderViewControllerMaker(forTypes types: [AVMetadataObject.ObjectType]) -> QRCodeReaderViewController {
        
        let builder = QRCodeReaderViewControllerBuilder {
            
            $0.reader = QRCodeReader(metadataObjectTypes: types, captureDevicePosition: .back)
            
            $0.showTorchButton = true
            $0.showSwitchCameraButton = true
            $0.showCancelButton = true
            $0.showOverlayView = true
            $0.rectOfInterest = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }
}

// MARK: - 資料相關
extension ProductActionViewController {
    
    /// 加入新書
    private func appendBook(_ sender: UIBarButtonItem) {
        
        guard let _isbn = isbnTextField.text,
              let _count = countTextField.text,
              let title = titleTextField.text,
              let isbn = Int(_isbn),
              let count = Int(_count),
              let timestamp = Optional.some(Int(Date().timeIntervalSince1970))
        else {
            return
        }
        
        FIRDatabase.shared.queryChildValue(isbn, withPath: "\(BookField.BarCode.realPath())", forKey: "\(BookField.ISBN)") { (_result) in
            
            KRProgressHUD.show()
            
            switch (_result) {
            case .failure(let error):
                KRProgressHUD.showError(withMessage: error.localizedDescription)
                
            case .success(let value):
                
                let isOK = self.checkValue(value, withType: self.tabBarType)
                
                if (!isOK) { return }
                
                let product = Book(isbn: isbn, title: title, url: nil, icon: nil, count: count, timestamp: timestamp).dictionary() as [String: Any]
                let realPath = BookField.BarCode.realPath(withBarCode: isbn)
                
                FIRDatabase.shared.updateChildValues(withPath: realPath, values: product) { (result) in
                    switch (result) {
                    case .failure(let error): KRProgressHUD.showError(withMessage: error.localizedDescription)
                    case .success(_): KRProgressHUD.showSuccess()
                    }
                }
            }
        }
    }
    
    /// 取得書本資訊
    private func searchBookInfomation(withBarCode barCode: Int?, forType type: TabBarType) {
        
        guard let barCode = barCode else { return }
        
        KRProgressHUD.show()
        
        _ = bookInfomation(withType: .single, barCode: barCode, result: { (_result) in
            switch (_result) {
            case .failure(let error):
                KRProgressHUD.showError(withMessage: error.localizedDescription)
            case .success(let value):
                KRProgressHUD.showSuccess()
                guard let _value = value as? [String: Any] else { return }
                self.textFieldTextSetting(withBook: Book.builder(with: _value), forType: type)
            }
        })
    }
    
    /// 更新書本數量
    private func updateBookCount(_ count: String?, barCode: String?, type: TabBarType) {
        
        guard let _count = count,
              let _barCode = barCode,
              let count = Int(_count),
              let barCode = Int(_barCode)
        else {
            return
        }
        
        let path = "\(BookField.BarCode.realPath(withBarCode: barCode))"
        var saveCount = 0
        
        switch type {
        case .plus: saveCount = (originalCount ?? 0) + count
        case .minus: saveCount = (originalCount ?? 0) - count
        case .cart, .fix, .stock: return
        }
        
        FIRDatabase.shared.setChildValue(saveCount, forKey: "\(BookField.Count)", path: path) { (result) in
            
            switch (result) {
            case .failure(let error):
                KRProgressHUD.showError(withMessage: error.localizedDescription)
            case .success(let isOK):
                if (!isOK) { KRProgressHUD.showError(); return }
                self.searchBookInfomation(withBarCode: Int(barCode), forType: type)
            }
        }
    }
    
    /// 取得firebase上的數值 (回傳handle代號)
    private func bookInfomation(withType type: RealtimeDatabaseType, barCode: Int ,result: @escaping (Result<Any?, Error>) -> Void) -> UInt? {
        
        let path = "\(BookField.BarCode.realPath(withBarCode: barCode))"
        
        let handleNumber = FIRDatabase.shared.childValueFor(type: type, path: path) { (_result) in
            switch(_result) {
            case .failure(let error): result(.failure(error))
            case .success(let value): result(.success(value))
            }
        }
        
        return handleNumber
    }
    
    /// 按下拍攝照片按鍵的動作
    private func photographAction(forType type: TabBarType) {
        
        switch type {
        case .minus, .plus, .stock: break
        case .cart, .fix:
            let pickerController = photoPickerController(with: .camera)
            pickerController.delegate = self
            present(pickerController, animated: true, completion: nil)
        }
    }
    
    /// 更新圖片
    private func updateWebImage(_ image: UIImage?) {
        
        guard let isbn = self.isbnTextField.text,
              let image = image
        else {
            return
        }
        
        KRProgressHUD.show()
        
        self.uploadImage(image, withISBN: isbn) { (_result) in
            
            switch (_result) {
            case .failure(_): KRProgressHUD.showError()
            case .success(_): self.downloadImageWithISBN(isbn, type: self.imageType)
            }
        }
    }
    
    /// 上傳圖片
    private func uploadImage(_ image: UIImage?, withISBN isbn: String?, result: @escaping (Result<StorageMetadata?, Error>) -> Void) {
        
        guard let isbn = isbn,
              let image = image
        else {
            return
        }
        
        _ = FIRStorage.shared.uploadImageWithName(isbn, forFolder: FIRStorage.imageFolder, image: image, type: imageType) { (_result) in
            switch(_result) {
            case .failure(let error): result(.failure(error))
            case .success(let metadata): result(.success(metadata))
            }
        }
    }
    
    /// 取得圖片URL
    private func imageURL(withISBN isbn: String, type: FIRStorage.ImageType, result: @escaping (Result<URL?, Error>) -> Void) {
        
        FIRStorage.shared.downloadImageWithName(isbn + type.rawValue, forFolder: FIRStorage.imageFolder, result: { (_result) in
            switch (_result) {
            case .failure(let error): result(.failure(error))
            case .success(let url): result(.success(url))
            }
        })
    }
    
    /// 下載圖片
    private func downloadImageWithISBN(_ isbn: String, type: FIRStorage.ImageType) {
        
        self.imageURL(withISBN: isbn, type: .jpeg, result: { (result) in
            switch (result) {
            case .failure(_): KRProgressHUD.showError()
            case .success(let url):
                KRProgressHUD.showSuccess()
                self.updateImageView(withURL: url)
            }
        })
    }
}

// MARK: - 小工具
extension ProductActionViewController {
    
    /// 初始化設定
    private func initSetting() {
        
        isbnTextField.leftImage = #imageLiteral(resourceName: "QRCode")
        titleTextField.leftImage = #imageLiteral(resourceName: "Writing")
        countTextField.leftImage = #imageLiteral(resourceName: "Countdown")
        
        isbnTextField.inputAccessoryView = myToolbar()
        titleTextField.inputAccessoryView = myToolbar()
        countTextField.inputAccessoryView = myToolbar()
    }
    
    /// 初始化NavigationItemTitle
    private func navigationItemTitleSetting(_ title: String) {
        navigationItem.title = title
    }
    
    /// 初始化TextField的狀態
    private func initSettingWithType(_ type: TabBarType) {
        
        switch type {
        case .stock: break
        case .cart, .fix:
            isbnTextField.isEnabled = false
        case .plus, .minus:
            isbnTextField.isEnabled = false
            titleTextField.isEnabled = false
        }
    }
    
    /// 清除輸入框文字
    private func clearTextFields() {
        isbnTextField.text = ""
        titleTextField.text = ""
        countTextField.text = ""
    }
    
    /// 設定文字框內容 (進貨 / 出貨 / 更新)
    private func textFieldTextSetting(withBook book: Book, forType type: TabBarType) {
        
        let isbn = book.isbn?.description ?? ""
        let title = book.title?.description ?? ""
        let count = book.count?.description ?? ""
        
        originalCountSetting(book.count)
        
        isbnTextField.text = isbn
        
        switch type {
        case .plus, .minus:
            titleTextField.text = title + " (\(count))"
            countTextField.text = String()
        case .fix:
            titleTextField.text = title
            countTextField.text = count
        case .stock, .cart:
            break
        }
    }
    
    /// 記錄原始的數量
    private func originalCountSetting(_ count: Int?) {
        originalCount = count
    }
    
    /// 更新圖片框
    private func updateImageView(withURL url: URL?) {
        self.productImageView.kf.indicatorType = .activity
        self.productImageView.kf.setImage(with: url)
    }
    
    /// 鍵盤上的Toolbar
    private func myToolbar() -> UIToolbar {
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))
        let doneItem = UIBarButtonItem(title: "確定", style: .done, target: self, action: #selector(dismissKeyboard(_:)))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [spaceItem, doneItem]
        
        return toolbar
    }
    
    /// 檢測是否要加入或更新的依據
    private func checkValue(_ value: Any?, withType type: TabBarType) -> Bool {
        
        switch type {
        case .cart:
            guard (value as? [String: Any] == nil) else { KRProgressHUD.showError(withMessage: "已經加入了過了"); return false }
            return true
        case .fix:
            if (value as? [String: Any] == nil) { KRProgressHUD.showError(withMessage: "沒有這個東西"); return false }
            return true
        case .plus, .minus, .stock:
            return false
        }
    }
    
    /// UIImagePicker基本相關設定
    private func photoPickerController(with sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        
        // 相機分類
        enum MediaType: String {
            case image = "public.image"
            case movie = "public.movie"
        }
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.mediaTypes = [MediaType.image.rawValue]
        imagePickerController.modalTransitionStyle = .flipHorizontal
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = false
        
        return imagePickerController
    }
}
