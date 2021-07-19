//
//  SecondViewController.swift
//  ToNextViewController
//
//  Created by William on 2019/8/2.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    let StoryboardID = "SecondNextViewController"
    let SegueID = "SecondSegueManual"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        print("identifier = \(identifier)")
    }

    @IBAction func goToNextPage(_ sender: UIBarButtonItem) {
        
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardID) {
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    @IBAction func goToNextViewController(_ sender: UIButton) {
        performSegue(withIdentifier: SegueID, sender: nil)
    }
    
    @IBAction func goToNextVC(_ sender: UIButton) {
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardID) {
            present(nextViewController, animated: true, completion: nil)
        }
    }
}
