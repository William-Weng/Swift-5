//
//  FIRDatabase.swift
//  Firebase_HelloWorld
//
//  Created by William on 2019/6/11.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import FirebaseDatabase

// MARK: - Firebase工具
class FIRDatabase: NSObject {
    
    public static let shard = FIRDatabase()
    public let database = Database.database().reference()
    
    private override init() { super.init() }
}

// MARK: - 主工具
extension FIRDatabase {
    
    /// 取值 (單次 / 及時)
    func childValueFor(type: RealtimeDatabaseType, withPath path: String, result: @escaping ((Any?) -> Void)) {
        
        switch type {
        case .single: childValueForSingle(withPath: path) { (value) in result(value) }
        case .realtime: childValueForRealtime(withPath: path) { (value) in result(value) }
        }
    }
    
    /// 設定數據
    func setChildValue(withPath path: String, value: Any, result: @escaping ((Any?) -> Void)) {

        let isOK = true
        
        database.child(path).setValue(value) { (error, database) in
            if error != nil { result(!isOK); return }
            result(isOK)
        }
    }
    
    /// 更新數據
    func updateChildValue(withPath path: String, values: [String: Any], result: @escaping ((Any?) -> Void)) {
        
        let isOK = true
        
        database.child(path).updateChildValues(values) { (error, database) in
            if error != nil { result(!isOK); return }
            result(isOK)
        }
    }
    
    /// 移除數據
    func removeChildValue(withPath path: String, result: @escaping ((Any?) -> Void)) {
        
        let isOK = true
        
        database.child(path).removeValue { (error, database) in
            if error != nil { result(!isOK); return }
            result(isOK)
        }
    }
    
    /// 查詢數據
    func queryChildValue(withPath path: String, byKey key: String, value: Int, result: @escaping ((Any?) -> Void)) {
        
        database.child(path).queryOrdered(byChild: key).queryEqual(toValue: value).observe(.value, with: { (snapshot) in
            result(snapshot.value)
        }, withCancel: { error in
            result(nil)
        })
    }
}

// MARK: - 小工具
extension FIRDatabase {
    
    /// 取值 (單次)
    private func childValueForSingle(withPath path: String, result: @escaping ((Any?) -> Void)) {
        
        database.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            result(snapshot.value)
        }, withCancel: { (error) in
            result(nil)
        })
    }
    
    /// 取值 (及時)
    private func childValueForRealtime(withPath path: String, result: @escaping ((Any?) -> Void)) {
        
        database.child(path).observe(.value, with: { (snapshot) in
            result(snapshot.value)
        }, withCancel: { (error) in
            result(nil)
        })
    }
}
