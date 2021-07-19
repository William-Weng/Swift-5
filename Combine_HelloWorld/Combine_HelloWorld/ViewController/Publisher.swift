//
//  Publisher.swift
//  Combine_HelloWorld
//
//  Created by William.Weng on 2020/9/17.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

// MARK: - 模擬Publisher (重點 => 拿Closure當屬性用)
struct Publisher<Value> {
    
    /// 重點就是這個 => struct一定會init含變數 => 包含結束的func
    let subscribe: (@escaping (Value?) -> Void) -> Subscription
    
    /// 也就是連續執行Publisher => 但形態不同 (值的轉換)
    func map<NewValue>(_ transform: @escaping (Value?) -> NewValue) -> Publisher<NewValue> {
        
        return Publisher<NewValue> { newHandler in
            
            /// 把上一次的Subscribe執行 => 再把下一次的Subscribe存起來
            let subscribe = self.subscribe { value in
                let newValue = transform(value)
                return newHandler(newValue)
            }
            
            return subscribe
        }
    }
}

// MARK: - 模擬Subscription (重點 => 拿Closure當屬性用，可以自己cancel()，或者是在物件消失的時候自動cancel())
final class Subscription {
    
    let cancel: () -> Void
    
    init(cancel: @escaping () -> Void) { self.cancel = cancel }
    
    deinit { cancel() }
}

// MARK: - URLSession
extension URLSession {
    
    /// Get的簡單Demo測試 (func開始 + 結束)
    func _sessionTask(urlString: String, dataHandler: @escaping (Data?) -> Void) -> Subscription {
        
        let url = URL(string: urlString)
        let task = dataTask(with: url!) { (data, response, error) in
            
            if let error = error { wwPrint(error); return }
            if let response = response { wwPrint(response) }
            
            dataHandler(data)
        }
        
        task.resume()
        
        /// 取消訂閱關係 => 就是把Task關掉
        return Subscription { task.cancel() }
    }
    
    /// 當然也可以打包一下 => Publisher<Data>
    func _dataTaskPublisher(urlString: String) -> Publisher<Data> {
        
        let publisher = Publisher<Data> { (handler) in
            
            /// 讀取完網路資料後，把Closure存起來 => Save (subscribe)
            self._sessionTask(urlString: urlString) { (data) in handler(data) }
        }
        
        return publisher
    }
}


