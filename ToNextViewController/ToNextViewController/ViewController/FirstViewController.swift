//
//  ViewController.swift
//  ToNextViewController
//
//  Created by William on 2019/8/2.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    let StoryboardID = "FirstNextViewController"
    let SegueID = "FirstSegueManual"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        print("identifier = \(identifier)")
    }
    
    @IBAction func goToNextPage(_ sender: UIButton) {
        performSegue(withIdentifier: SegueID, sender: nil)
    }
    
    @IBAction func goToNextViewController(_ sender: UIButton) {
        
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardID) {
            present(nextViewController, animated: true, completion: nil)
        }
    }
}

