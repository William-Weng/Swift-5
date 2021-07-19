//
//  ViewController.swift
//  MyLocation
//
//  Created by William.Weng on 2021/5/31.
//

import UIKit
import CoreLocation

// MARK: - 我到底身在何方？我到底去到何處？
final class ViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationName = Notification._name(._locationServices)
        
        NotificationCenter.default._register(name: notificationName) { notification in
            self.resultLabel.text = notification.object.debugDescription
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Utility.shared.locationManager._locationServicesAuthorizationStatus {
            wwPrint("alwaysHandler")
        } whenInUseHandler: {
            wwPrint("whenInUseHandler")
        } deniedHandler: {
            self.resultLabel.text = "\(CLLocationManager._locationCountryCode())"
        }
    }
}


