//
//  ViewController.swift
//  ManualController
//
//  Created by William.Weng on 2021/11/9.
//

import UIKit

final class ViewController: UIViewController {

    private(set) var color: UIColor = .yellow
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
    }
    
    func configure(with color: UIColor = .yellow) {
        self.color = color
        self.view.backgroundColor = color
    }
    
    deinit {
        print("deinit")
    }
}
