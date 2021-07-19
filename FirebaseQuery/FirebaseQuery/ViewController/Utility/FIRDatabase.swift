//
//  FIRDatabase.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/12.
//  Copyright © 2019 William. All rights reserved.
//
/// https://console.firebase.google.com/?hl=zh-TW

import UIKit
import FirebaseDatabase

// MARK: - Firebase工具
class FIRDatabase: NSObject {

    public static let shared = FIRDatabase()
    
    private let reference = Database.database().reference()
    
    private override init() { super.init() }
}

// MARK: - 主工具
extension FIRDatabase {
    
    /// 取值 (單次 / 及時) => 回傳realtime的handle代號
    func childValueFor(type: RealtimeDatabaseType, path: String, result: @escaping (Result<Any?, Error>) -> Void) -> UInt? {
        
        var handleNumber: UInt?
        
        switch type {
        case .single:
            handleNumber = childValueForSingle(withPath: path) { (_result) in
                switch(_result) {
                case .failure(let error): result(.failure(error))
                case .success(let value): result(.success(value))
                }
            }
            
        case .realtime:
            handleNumber = childValueForRealtime(withPath: path) { (_result) in
                switch(_result) {
                case .failure(let error): result(.failure(error))
                case .success(let value): result(.success(value))
                }
            }
        }
        
        return handleNumber
    }
    
    /// 移除Realtime的Handle
    func removeObserver(withHandle handleNumber: UInt?) {
        guard let handleNumber = handleNumber else { return }
        reference.removeObserver(withHandle: handleNumber)
    }
    
    /// 更新數據 (單個)
    func setChildValue(_ value: Any?, forKey key: String, path: String, result: @escaping (Result<Bool, Error>) -> Void) {
        
        reference.child(path).child(key).setValue(value) { (error, database) in
            if let error = error { result(.failure(error)); return }
            result(.success(true))
        }
    }
    
    /// 更新數據 (多個)
    func updateChildValues(withPath path: String, values: [String: Any], result: @escaping (Result<Bool, Error>) -> Void) {
        
        reference.child(path).updateChildValues(values) { (error, database) in
            if let error = error { result(.failure(error)); return }
            result(.success(true))
        }
    }

    /// 移除資料
    func removeChildValue(withPath path: String, forKey key: String, result: @escaping (Result<Bool, Error>) -> Void) {
        
        reference.child(path).child(key).removeValue { (error, database) in
            if let error = error { result(.failure(error)); return }
            result(.success(true))
        }
    }
    
    /// 搜尋數據
    func queryChildValue(_ value: Any?, withPath path: String, forKey key: String, result: @escaping (Result<Any?, Error>) -> Void) {
        
        reference.child(path).queryOrdered(byChild: key).queryEqual(toValue: value).observeSingleEvent(of: .value, with: { (snapshot) in
            result(.success(snapshot.value))
        }, withCancel: { (error) in
            result(.failure(error))
        })
    }
}

// MARK: - 小工具
extension FIRDatabase {
    
    /// 取值 (單次)
    private func childValueForSingle(withPath path: String, result: @escaping (Result<Any?, Error>) -> Void) -> UInt? {
        
        reference.child(path).queryOrdered(byChild: "\(BookField.ISBN)").observeSingleEvent(of: .value, with: { (snapshot) in
            result(.success(snapshot.value))
        }, withCancel: { (error) in
            result(.failure(error))
        })
        
        return nil
    }
    
    /// 取值 (及時) => 回傳realtime的handle代號
    private func childValueForRealtime(withPath path: String, result: @escaping (Result<Any?, Error>) -> Void) -> UInt? {

        let handleNumber = reference.child(path).queryOrderedByKey().observe(.value, with: { (snapshot) in
            result(.success(snapshot.value))
        }, withCancel: { (error) in
            result(.failure(error))
        })
        
        return handleNumber
    }
}
