//
//  ViewController.swift
//  Firebase_HelloWorld
//
//  Created by William on 2019/6/11.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import FirebaseDatabase

// MARK: - ViewController
class ViewController: UIViewController {

    @IBOutlet var myTableView: UITableView!
    
    var bookInfomations = [BookInfomation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readBooksInfomation(forType: .realtime)
    }
    
    /// 設定數值
    @IBAction func setValue(_ sender: UIBarButtonItem) {
        
        let database = FIRDatabase.shard
        let path = "Books/0/"
        let value = ["ISBN": Int(Date().timeIntervalSince1970)]
        
        database.setChildValue(withPath: path, value: value) { (isOK) in
            print(isOK!)
        }
    }
    
    /// 更新數值
    @IBAction func updateValue(_ sender: UIBarButtonItem) {
        
        let database = FIRDatabase.shard
        let path = "Books/0/"
        let values = ["ISBN": Int(Date().timeIntervalSince1970)]
        
        database.updateChildValue(withPath: path, values: values) { (isOK) in
            print(isOK!)
        }
    }
    
    /// 刪除數值
    @IBAction func removeValue(_ sender: UIBarButtonItem) {
        
        let database = FIRDatabase.shard
        let path = "Books/0/ISBN"
        
        database.removeChildValue(withPath: path) { (isOK) in
            print(isOK!)
        }
    }
    
    /// 查詢數值
    @IBAction func queryValue(_ sender: UIBarButtonItem) {
        queryBooksInfomation(byKey: "ISBN", value: 9789863843344)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookInfomations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let myCell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier) as? MyTableViewCell else { return UITableViewCell() }
        
        myCell.configure(bookInfomations[indexPath.row])
        return myCell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard let url = bookInfomations[indexPath.row].url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 設定TableView
    private func initSetting() {
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    /// 讀取Firebase的資料 (更新)
    private func readBooksInfomation(forType type: RealtimeDatabaseType) {
        
        let database = FIRDatabase.shard
        let path = "Books/"

        database.childValueFor(type: type, withPath: path) { (value) in
            self.bookInfomations = self.bookInfomationsMaker(with: value)
            self.myTableView.reloadData()
        }
    }
    
    /// 查詢Firebase的資料 (更新 / 排序)
    private func queryBooksInfomation(byKey key: String, value: Int) {
        
        let database = FIRDatabase.shard
        let path = "Books/"
        
        database.queryChildValue(withPath: path, byKey: key, value: value) { (value) in
            self.bookInfomations = self.bookInfomationsMaker(with: value)
            self.myTableView.reloadData()
        }
    }
    
    /// 解析資料
    private func bookInfomationsMaker(with value: Any?) -> [BookInfomation] {
        
        var bookInfomations = [BookInfomation]()
        
        guard let array = value as? [Any] else { return bookInfomations }
        
        for data in array {
            if let dict = data as? [String: Any] {
                let info = BookInfomation.configure(with: dict)
                bookInfomations.append(info)
            }
        }
        
        return bookInfomations
    }
}
