//
//  FIRDatabase.swift
//  FirebaseOrder
//
//  Created by William on 2019/6/20.
//  Copyright © 2019 William. All rights reserved.
//
/// https://console.firebase.google.com/?hl=zh-TW

import UIKit
import FirebaseDatabase

// MARK: - Firebase工具
class FIRDatabase: NSObject {
    
    /// 排序的類型
    enum OrderType {
        case none
        case queryOrderedByKey
        case queryOrderedByValue
        case queryOrderedByPriority
        case queryOrderedByChild(field: Book.Field)
    }
    
    public static let shared = FIRDatabase()
    private let reference = Database.database().reference()
    private override init() { super.init() }
}

// MARK: - 小工具
extension FIRDatabase {

    /// 取得資料 (及時)
    func childValueForRealtime(withPath path: String, orderType type: OrderType ,result: @escaping (Result<DataSnapshot?, Error>) -> Void) -> UInt? {
        
        let _reference = reference.child(path)
        var queryReference: DatabaseQuery?
        
        switch type {
        case .none: queryReference = _reference
        case .queryOrderedByKey: queryReference = _reference.queryOrderedByKey()
        case .queryOrderedByValue: queryReference = _reference.queryOrderedByValue()
        case .queryOrderedByPriority: queryReference = _reference.queryOrderedByPriority()
        case .queryOrderedByChild(let field): queryReference = _reference.queryOrdered(byChild: field.rawValue)
        }
        
        let handleNumber = queryReference?.observe(.value, with: { (snapshot) in
            result(.success(snapshot))
        }, withCancel: { (error) in
            result(.failure(error))
        })
        
        return handleNumber
    }
}
