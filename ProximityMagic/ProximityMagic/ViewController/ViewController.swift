//
//  ViewController.swift
//  ProximityMagic
//
//  Created by William on 2019/5/25.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var pokerImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        pokerImageView.isHidden = true
        
        UIDevice.current.isProximityMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(show(notification:)), name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }

    private func showPokerImage(_ image: UIImage?) {
        pokerImageView.image = image ?? #imageLiteral(resourceName: "JokerRed")
        pokerImageView.isHidden = false
    }
    
    @objc private func show(notification: NSNotification) {
        
        let database = FIRDatabase.shared
        let Key = "Poker"
        
        database.allValues(result: { (array) in
            
            if let pokerArray = array as? [String: String] {
                if let imagename = pokerArray[Key] {
                    self.showPokerImage(UIImage.init(named: imagename))
                }
            }
        })
    }
}

