//
//  ViewController.swift
//  FirebaseOrder
//
//  Created by William on 2019/6/20.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    @IBOutlet var myTableView: UITableView!
    
    var books = [Book]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        booksForRealtime()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let myCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") else { return UITableViewCell() }
        
        let book = books[indexPath.row]
        
        myCell.textLabel?.text = "\(book.ISBN ?? 0)"
        myCell.detailTextLabel?.text = book.Title
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 初始化設定
    private func initSetting() {
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    /// 取得書本資料
    private func booksForRealtime() {
        
        let path = "Books/BarCode"
        
        _ = FIRDatabase.shared.childValueForRealtime(withPath: path, orderType: .queryOrderedByChild(field: .ISBN)) { (result) in
            
            switch(result) {
            case .failure(let error): print(error)
            case .success(let snapshot):
                guard let snapshot = snapshot else { return }
                self.books = self.booksMaker(withChildren: snapshot.children)
                self.myTableView.reloadData()
            }
        }
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 產生[book]
    private func booksMaker(withChildren children: NSEnumerator) -> [Book] {
        
        var books = [Book]()
        
        for child in children {
            
            if let child = child as? DataSnapshot {
                
                let bookData = child.value as? [String: Any]
                if let book = self.bookMaker(withValue: bookData) { books.append(book) }
            }
        }
        
        return books
    }
    
    /// 產生book
    private func bookMaker(withValue value: [String: Any]?) -> Book? {
        
        guard let value = value,
              let isbn = value["ISBN"] as? Int,
              let title = value["Title"] as? String
        else {
            return nil
        }
        
        let book = Book(ISBN: isbn, Title: title)
        
        return book
    }
}
