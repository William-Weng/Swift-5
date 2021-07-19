//
//  ViewController.swift
//  SparkView
//
//  Created by William on 2019/8/26.
//  Copyright © 2019 William. All rights reserved.
//
/// [給 UIView 來點煙花](https://swift.gg/2019/08/14/add-fireworks-and-sparks-to-a-uiview/)
/// [Add fireworks and sparks to a UIView](http://szulctomasz.com/programming-blog/2018/09/add-fireworks-and-sparks-to-a-uiview/)

import UIKit

class ViewController: UIViewController {

    private let fireworkController = ClassicFireworkController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func show(_ sender: UIButton) {
        fireworkController.addFireworks(count: 2, sparks: 8, around: sender)
    }
}

