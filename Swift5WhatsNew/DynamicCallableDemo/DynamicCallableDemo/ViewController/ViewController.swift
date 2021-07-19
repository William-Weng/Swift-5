//
//  ViewController.swift
//  DynamicCallableDemo
//
//  Created by William on 2019/4/2.
//  Copyright © 2019 William. All rights reserved.
//
/// [Swift 5 新特性詳解：ABI 穩定終於來了！](https://www.infoq.cn/article/pwIjo5GiXxzQYM_hRRGx)
/// [How to use @dynamicCallable in Swift](https://www.hackingwithswift.com/articles/134/how-to-use-dynamiccallable-in-swift)

import UIKit
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func functionCall(_ sender: UIButton) {
        testFunctionCall()
    }
    
    @IBAction func dynamicallyCall(_ sender: UIButton) {
        testDynamicallyCall()
    }
}

// MARK: - 小工具
extension ViewController {
    
    /// 利用一般的方式去處理
    private func testFunctionCall() {
        
        let random = RandomNumberGenerator()
        let result = random.generate(numberOfZeroes: 0)
        
        print(result)
    }
    
    /// 利用動態參數當引數去處理 (js？python？)
    private func testDynamicallyCall() {
        
        let random = RandomNumberGeneratorDynamic()
        let result = random(0)
        // let result = random(numberOfZeroes: 0)
        // let result = random.dynamicallyCall(withKeywordArguments: ["numberOfZeroes": 0])
        
        print(result)
    }
}

// MARK: - 比較
struct RandomNumberGenerator {
    
    func generate(numberOfZeroes: Int) -> Double {
        let maximum = pow(10, Double(numberOfZeroes))
        return Double.random(in: 0...maximum)
    }
}

@dynamicCallable
struct RandomNumberGeneratorDynamic {
    
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Double {
    
        let numberOfZeroes = Double(args.first?.value ?? 0)
        let maximum = pow(10, numberOfZeroes)
        
        return Double.random(in: 0...maximum)
    }
    
    func dynamicallyCallMethod(named: String, withKeywordArguments: KeyValuePairs<String, Int>) {}
}



