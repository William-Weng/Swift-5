//
//  ViewController.swift
//  ThreadSafety
//
//  Created by William.Weng on 2022/11/2.
//
/// https://youtu.be/dmHnk3SlL6g

import UIKit
import WWPrint
import SwiftUI

final class ViewController: UIViewController {
    
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myView: UIView!

    private let lock = NSLock._build(name: "MyLock")
    private let condition = NSCondition._build(name: "MyCondition")
    private let bufferSize = 20
    
    private var count = 0
    private var items = [String]()
    private var products = [String]()
    private var model = UserDashboardModel()
    
    @Atomic var number: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lock.name = "MyLock"
        model.markdownString = "[Google](https://www.google.com)"
    }
    
    @IBSegueAction func showSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        
        if #available(iOS 15, *) {
            let viewController = UIHostingController(coder: coder, rootView: SwiftUIText(model: model))
            return viewController
        }
        
        return nil
    }
    
    @IBAction func demo0(_ sender: UIBarButtonItem) {
        threadNotSafetyDemo0()
        
        let markdownString = "[Google](https://www.google.com)"
        
        if #available(iOS 15, *) {
            myTextView.attributedText = try! NSAttributedString(markdown: markdownString)
        }
    }
    
    @IBAction func demo1(_ sender: UIBarButtonItem) {
        threadNotSafetyDemo1()
        // if #available(iOS 15, *) { model.markdownString = "[簡介 SwiftUI & 用其建構一簡單的 App](https://www.jianshu.com/p/e589181b14db)" }
    }
    
    @IBAction func demo2(_ sender: UIBarButtonItem) {
        items = [String]()
        threadNotSafetyDemo2()
    }
    
    @IBAction func demo3(_ sender: UIBarButtonItem) {
        products = [String]()
        threadNotSafetyDemo3()
    }
    
    @IBAction func demo4(_ sender: UIBarButtonItem) {
        number = 0
        threadNotSafetyDemo4()
    }
}

private extension ViewController {
    
    func threadNotSafetyDemo0() {
        
        let date = Date._now()
        
        count = 0
        number = 0
        
        for _ in 0..<20000 { self.increment0() }
        
        wwPrint("處理完成的時間 => \(date._elapsedTime())")
    }
    
    /// [同時執行兩個Thread同加一個數](http://shoshino21.logdown.com/posts/7818726)
    /// => (✖) 20000
    func threadNotSafetyDemo1() {
                
        let date = Date._now()
        let group = DispatchGroup()
        let queue1 = DispatchQueue(label: "demo1-1", attributes: .concurrent)
        let queue2 = DispatchQueue(label: "demo1-2", attributes: .concurrent)

        count = 0
        number = 0
        
        group.enter()
        queue1.async(group: group, qos: .default) {
            for _ in 0..<10000 { self.increment1() }
            wwPrint("我是demo1-1，我完成了")
            group.leave()
        }
        
        group.enter()
        queue2.async(group: group, qos: .default) {
            for _ in 0..<10000 { self.increment1() }
            wwPrint("我是demo1-2，我完成了")
            group.leave()
        }
                
        group.notify(queue: .main) {
            wwPrint("處理完成Queue1和Queue2的時間 => \(date._elapsedTime())")
        }
    }
    
    /// [加1](https://onevcat.com/2021/07/swift-concurrency/)
    func increment0() {
        count += 1
        self.myLabel.text = "\(self.count)"
        wwPrint(count)
    }
    
    /// [加1](https://onevcat.com/2021/09/structured-concurrency/)
    func increment1() {
                
        let _count = lock._threadSafety {
            count += 1
            DispatchQueue.main.async { self.myLabel.text = "\(self.count)" }
            return count
        }
        
        wwPrint(_count)
    }
    
    /// <互斥鎖> 加1
    func increment2() {
        
        let _count = NSLock._synchronized(token: self) {
            count += 1
            DispatchQueue.main.async { self.myLabel.text = "\(self.count)" }
            return count
        }
        
        wwPrint(_count)
    }
}

private extension ViewController {
    
    /// 同時執行兩個Thread一起處理一個Array
    /// => (✖) crash / out of bounds
    func threadNotSafetyDemo2() {
                
        DispatchQueue.global(qos: .default).async {
            for _ in 0...10000 { self.switchItem() }
        }
        
        DispatchQueue.global(qos: .default).async {
            for _ in 0...10000 { self.printItem() }
        }
    }
    
    /// 讓Item只會有一個值
    func switchItem() {
        
        lock._threadSafety {
            if (items.isEmpty) { items.append("Apple"); return }
            items.remove(at: 0)
        }
    }
    
    /// 列印Item[0]
    func printItem() {
        
        lock._threadSafety {
            if (items.isEmpty) { return }
            let firstItem = items[0]
            DispatchQueue.main.async { self.myLabel.text = "\(firstItem)" }
        }
    }
}

private extension ViewController {
    
    // https://franksios.medium.com/ios-gcd多執行緒的說明與應用-c69a68d01da1
    func threadNotSafetyDemo3() {
        
        DispatchQueue.global(qos: .default).async {
            while (true) { self.triggerProducer() }
        }
        
        DispatchQueue.global(qos: .default).async {
            while (true) { self.triggerConsumer() }
        }
    }
    
    func triggerProducer() {
        
        let result = condition._threadSafety {
            products.append("APPLE")
            return products
        } wait: {
            return products.count == bufferSize
        }
        
        wwPrint("triggerProducer => \(result.count)")
    }
    
    func triggerConsumer() {
        
        let result = condition._threadSafety {
            products.remove(at: 0)
            return products
        } wait: {
            return products.count == 0
        }
        
        wwPrint("triggerConsumer => \(result.count)")
    }
}

extension ViewController {
    
    func threadNotSafetyDemo4() {
        
        number = 0
        
        DispatchQueue.global(qos: .default).async {
            for _ in 0..<10000 {
                self._number.action { $0 += 1 }
                wwPrint("\(self.number)")
                DispatchQueue.main.async { self.myLabel.text = "\(self.number)" }
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            for _ in 0..<10000 {
                self._number.action { $0 += 1 }
                wwPrint("\(self.number)")
                DispatchQueue.main.async { self.myLabel.text = "\(self.number)" }
            }
        }
    }
}

