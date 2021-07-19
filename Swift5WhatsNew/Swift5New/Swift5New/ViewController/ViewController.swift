//
//  ViewController.swift
//  Swift5New
//
//  Created by William on 2019/4/3.
//  Copyright © 2019 William. All rights reserved.
//
/// [Swift 5.0 新特性](https://www.jianshu.com/p/afa74763b78b)

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func testMultiple(_ sender: UIButton) {
        showＭultipleOfNumber(4, multiple: 2)
    }
    
    @IBAction func testCompactMapValues(_ sender: UIButton) {
        showCompactMapValues()
    }
}

// MARK: - 測試
extension ViewController {
    
    /// 新判斷倍數的函式 (4 % 2 == 0 ==> isMultiple(of:))
    private func showＭultipleOfNumber(_ number: Int, multiple: Int) {
        
        let rowNumber = 4
        let result = rowNumber.isMultiple(of: multiple) ? "Even" : "Old"
        
        print(result)
    }
    
    /// 過濾 => compactMap()
    private func showCompactMapValues() {
        
        let times = [
            "Hudson": "38",
            "Clarke": "42",
            "Robinson": "35",
            "Hartis": "DNF"
        ]
        
        let people = [
            "Paul": 38,
            "Sophie": 8,
            "Charlotte": 5,
            "William": nil
        ]
        
        // 過濾DNF
        let finishers = times.compactMapValues { Int($0) }
        // let finishers = times.compactMapValues(Int.init)

        // 過濾nil
        let knownAges = people.compactMapValues { $0 }
        
        print(finishers)
        print(knownAges)
    }
}
