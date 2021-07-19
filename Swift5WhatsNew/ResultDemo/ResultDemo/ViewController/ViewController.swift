//
//  ViewController.swift
//  Swift-5_Test
//
//  Created by William on 2019/4/2.
//  Copyright © 2019 William. All rights reserved.
//
/// 比較三種寫法的差異
/// [What’s new in Swift 5.0](https://www.hackingwithswift.com/articles/126/whats-new-in-swift-5-0)

import UIKit

class ViewController: UIViewController {

    let urlString = "https://www.hackingwithswift.com"
    
    /// 自定義Error
    private enum NetWorkError: Error {
        case badURL
    }
    
    /// 自定義Error
    enum FactorError: Error {
        case belowMinimum
        case isPrime
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// ★★★ 使用Result的寫法 => 利用enum，直接把『值 / 錯誤分開』
    @IBAction func testResult(_ sender: UIButton) {
        
        fetchUnreadCount_1(from: urlString) { (result) in
            
            switch result {
            case .failure(let error):
                print("\(error.localizedDescription)")
            case .success(let count):
                print("\(count) unread message.")
            }
        }
    }

    /// ★★☆ 使用Closure的寫法 => 直接把『值 / 錯誤分開』，但後續還是要做if的判斷
    @IBAction func testClosure(_ sender: UIButton) {
        
        fetchUnreadCount_2(from: urlString) { (count, error) in
            
            if let error = error { print("\(error.localizedDescription)"); return }
            
            guard let count = count else { return }
            
            print("\(count) unread message.")
        }
    }
    
    /// ★☆☆ 使用Throws的寫法 => 利用try catch本身有丟出error的功能，但是code就比較雜一點了
    @IBAction func testThrows(_ sender: UIButton) {
        
        fetchUnreadCount_3(from: urlString) { (resultFunction) in
            
            do {
                let count = try resultFunction()
                print("\(count) unread message.")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func randomNumber(_ sender: UIButton) {
        
        let number = generateRandomNumber(maximum: 11)
        
        let stringNumber = number.map({ (num) in
            return "The random number is: \(num)"
        })
        
        print("stringNumber = \(stringNumber)")
    }
    
    /// 直接取值 => get()
    @IBAction func getContentOfFile(_ sender: UIButton) {
        
        let result = readContentOfFile()
        
        if let fileString = try? result.get() {
            print("\(fileString)")
        }
    }
    
    /// 利用map()去處理 Result<Result> => 打平
    @IBAction func getCalculatedFactors(_ sender: UIButton) {
        
        let result = generateRandomNumber(maximum: 10)
        let flatMapResult = result.flatMap { calculateFactors(for: $0) }
        
        print("flatMapResult => \(flatMapResult)")
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// Result<Int, Error>測試
    private func fetchUnreadCount_1(from urlString: String, completionHandler: (Result<Int, NetWorkError>) -> Void) {
        
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(.badURL)); return
        }
        
        print("URL_1 = \(url.absoluteString)")
        completionHandler(.success(5))
    }
    
    /// cloure測試 (會有四種可能要處理)
    private func fetchUnreadCount_2(from urlString: String, completionHandler: (Int?, NetWorkError?) -> Void) {
        
        guard let url = URL(string: urlString) else {
            completionHandler(nil, .badURL); return
        }
        
        print("URL_2 = \(url.absoluteString)")
        completionHandler(5, nil)
    }
    
    /// try catch 測試
    private func fetchUnreadCount_3(from urlString: String, completionHandler: @escaping (() throws -> Int) -> Void) {
        
        guard let url = URL(string: urlString) else {
            completionHandler { throw NetWorkError.badURL }; return
        }
        
        print("URL_3 = \(url.absoluteString)")
        completionHandler { return 5 }
    }
    
    /// 直接使用Result (取代try catch)
    private func readContentOfFile() -> Result<String, Error> {
        
        let filePath = Bundle.main.path(forResource: "doc", ofType: "txt")
        let result = Result { try String(contentsOfFile: filePath!) }
        
        return result
    }
    
    /// 實際範例 1
    private func generateRandomNumber(maximum: Int) -> Result<Int, FactorError> {
        
        if maximum < 0 { return .failure(.belowMinimum) }
        
        let number = Int.random(in: 0...maximum)
        return .success(number)
    }
    
    /// 實際範例 2
    private func calculateFactors(for number: Int) -> Result<Int, FactorError> {
        
        let factors = (1...number).filter { number % $0 == 0 }
        
        if factors.count == 2 { return .failure(.isPrime) }
        return .success(factors.count)
    }
}



