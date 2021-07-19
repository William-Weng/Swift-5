//
//  StockViewController.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/12.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import KRProgressHUD

// MARK: - 庫存清單
class StockViewController: UIViewController {

    @IBOutlet var myTableView: UITableView!
    
    let imageType: FIRStorage.ImageType = .jpeg
    
    var handleNumber: UInt?
    var stockProducts = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
        initValues()
    }
    
    deinit {
        FIRDatabase.shared.removeObserver(withHandle: handleNumber)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension StockViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let myCell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.Identifier) as? StockTableViewCell else { return UITableViewCell() }
        
        myCell.configure(with: stockProducts[indexPath.row])
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            
            guard let path = Optional.some("\(BookField.BarCode.realPath())"),
                  let isbn = stockProducts[indexPath.row].isbn
            else {
                return
            }
            
            self.removeBook(withPath: path, forKey: "\(isbn)") { (result) in
                
                switch (result) {
                case .failure(let error): KRProgressHUD.showError(withMessage: error.localizedDescription)
                case .success(_):
                    self.removeBookImage(withISBN: "\(isbn)", result: { (isOK) in
                        KRProgressHUD.showSuccess()
                    })
                }
            }
        }
    }
}

// MARK: - 主工具
extension StockViewController {
    
    /// 初始化設定
    private func initSetting() {
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    /// 取得數值的初始設定
    private func initValues() {
        
        KRProgressHUD.show()
        
        let _handleNumber = bookInfomation(withType: .realtime) { (result) in
            
            switch(result) {
            case .failure(let error):
                KRProgressHUD.showError(withMessage: error.localizedDescription)
            case .success(let value):
                KRProgressHUD.showSuccess()
                self.stockProducts = self.stockProductMaker(with: value)
                self.myTableView.reloadData()
            }
        }
        
        handleNumber = _handleNumber
    }
    
    /// 產生Product資料
    private func stockProductMaker(with values: Any?) -> [Book] {
        
        var stockProducts = [Book]()
        
        guard let values = values as? [String: Any] else { return stockProducts }
        
        for _value in values {
            
            if let _value = _value.value as? [String: Any] {
               let _product = Book.builder(with: _value)
                stockProducts.append(_product)
            }
        }
        
        return stockProducts
    }
}

/// MARK: - 小工具
extension StockViewController {
    
    /// 取得firebase上的數值 (回傳handle代號)
    private func bookInfomation(withType type: RealtimeDatabaseType, result: @escaping (Result<Any?, Error>) -> Void) -> UInt? {
        
        let handleNumber = FIRDatabase.shared.childValueFor(type: type, path: "\(BookField.BarCode.realPath())") { (_result) in
            switch(_result) {
            case .failure(let error): result(.failure(error))
            case .success(let value): result(.success(value))
            }
        }
        
        return handleNumber
    }
    
    /// 移除書籍
    private func removeBook(withPath path: String, forKey key: String, result: @escaping (Result<Bool, Error>) -> Void) {
        
        FIRDatabase.shared.removeChildValue(withPath: path, forKey: key) { (_result) in
            
            switch (_result) {
            case .failure(let error): result(.failure(error))
            case .success(let isOK): result(.success(isOK))
            }
        }
    }
    
    /// 移除書籍圖片
    private func removeBookImage(withISBN isbn: String, result: @escaping (Bool) -> Void) {

        FIRStorage.shared.removeImage(withName: isbn, forFolder: FIRStorage.imageFolder, type: imageType) { (isOK) in
            result(isOK)
        }
    }
}
