//
//  Views.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/12.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class MyTextField: UITextField {
    
    var leftImage: UIImage = #imageLiteral(resourceName: "NoImage") {
        willSet {
            let _leftView = UIImageView(image: newValue)
            leftView = _leftView
            leftViewMode = .always
        }
    }
}
