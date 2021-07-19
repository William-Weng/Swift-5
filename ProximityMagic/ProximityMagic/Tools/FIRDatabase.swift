//
//  FIRDatabase.swift
//  ProximityMagic
//
//  Created by William on 2019/5/25.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Firebase

class FIRDatabase: NSObject {
    
    public static let shared = FIRDatabase()
    private let database = Database.database().reference()
    
    private override init() { super.init() }
    
    /// 取得所有數據
    func allValues(result: @escaping ([String : Any]?) -> Void) {
        
        database.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDict = snapshot.value as? [String: Any] else { result(nil); return }
            result(userDict)
        }, withCancel: nil)
    }
}

