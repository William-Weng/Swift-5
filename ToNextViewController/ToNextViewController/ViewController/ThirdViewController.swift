//
//  ThirdViewController.swift
//  ToNextViewController
//
//  Created by William on 2019/8/2.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    let StoryboardID = "ThirdNextViewController"
    let SegueID = "ThirdSegueManual"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goToNextViewController(_ sender: UIButton) {
        performSegue(withIdentifier: SegueID, sender: nil)
    }
    
    @IBAction func goToNextVC(_ sender: UIButton) {
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardID) {
            present(nextViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func goToNextTab(_ sender: UIButton) {
        tabBarController?.selectedIndex = 1
    }
}
