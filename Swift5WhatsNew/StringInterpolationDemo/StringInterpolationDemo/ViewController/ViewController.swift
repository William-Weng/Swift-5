//
//  ViewController.swift
//  Swift_5
//
//  Created by William on 2019/4/2.
//  Copyright © 2019 William. All rights reserved.
//
/// [Swift 5 字符串插值之美](https://swift.gg/2019/02/21/the-beauty-of-swift-5-string-interpolation/)
/// [Swift 5.0 增强的字符串插值及格式化](https://itreefly.com/posts/3bf40970.html)

import UIKit

struct User {
    var name: String
    var age: Int
}

// MARK: - 主程式
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // showRawString()
        // showStringInterpolation()
    }
}

// MARK: - 未加工過的文字 (##)
extension ViewController {
    
    /// 顯示未加工過的文字
    private func showRawString() {
        print(rawString_1())
        print(rawString_2())
        print(rawString_3())
        print(rawString_4())
    }
    
    /// 未加工過的文字 (##)
    private func rawString_1() -> String {
        
        let answer = 42
        let dontpanic = #"The answer to lift, the universe, and everything is \#(answer)"#
        
        return dontpanic
    }
    
    /// 未加工過的文字 - 內含#文字 (## ##)
    private func rawString_2() -> String {
        
        let str = ##"My dog said "woof"#gooddog"##
        return str
    }
    
    /// 未加工過的文字 - 多行 (##)
    private func rawString_3() -> String {
        
        let answer = "36"
        let multiline = #"""
            The answer to life,
            the universe,
            and everything is \#(answer).
        """#
        
        return multiline
    }
    
    /// 未加工過的文字 - 正規式 (##)
    private func rawString_4() -> String {
        let regex = #"\\[A-Z]+[A-Za-z]+\.[a-z]+"#
        return regex
    }
}

// MARK: - String.StringInterpolation
extension ViewController {
    
    /// 顯示StringInterpolation
    private func showStringInterpolation() {
        print(testStringInterpolation_1())
        print(testStringInterpolation_2())
        print(testStringInterpolation_3())
        print(testStringInterpolation_4())
    }
    
    /// 跟CustomStringConvertible協定一樣
    private func testStringInterpolation_1() -> String {
        let user = User(name: "Guybrush Threepwood", age: 33)
        return "User details: \(user)"
    }
    
    /// 加強版的CustomStringConvertible協定 => 可以帶參數 (數字格式)
    private func testStringInterpolation_2() -> String {
        
        let number = Int.random(in: 0...100)
        let lucky = "The lucky number this week is \(number, style: .spellOut)."
        
        return lucky
    }
    
    /// 加強版的CustomStringConvertible協定 => 可以帶參數 (日期格式)
    private func testStringInterpolation_3() -> String {
        return "\(Date(), using: .full)"
    }
    
    /// 加強版的CustomStringConvertible協定 => 有帶Closure
    private func testStringInterpolation_4() -> String {
        let doesSwiftRock = true
        return "Swift rocks: \(if: doesSwiftRock, "(*)")"
    }
}

// MARK: - 自定義文字的插值 => \(指的是這個) (description的加強版)
extension String.StringInterpolation {
    
    mutating func appendInterpolation(_ value: User) {
        appendInterpolation("My name is \(value.name) and I'm \(value.age)")
    }
    
    mutating func appendInterpolation(_ number: Int, style: NumberFormatter.Style) {
    
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        
        if let result = formatter.string(from: number as NSNumber) {
            appendLiteral(result)
        }
    }
    
    mutating func appendInterpolation(_ value: Date, using style: DateFormatter.Style) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = style
        
        let dateString = formatter.string(from: value)
        appendLiteral(dateString)
    }
    
    mutating func appendInterpolation(if condition: @autoclosure () -> Bool, _ literal: StringLiteralType) {
        guard condition() else { return }
        appendLiteral(literal)
    }
}

