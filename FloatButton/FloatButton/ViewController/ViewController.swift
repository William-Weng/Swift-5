//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2022/12/20.

import UIKit
import WWPrint

final class ViewController: UIViewController {
    
    @IBOutlet weak var myFloatButton: WWFloatButton!
    @IBOutlet weak var myImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myFloatButton.myDelegate = self
    }
}

// MARK: - WWFloatButtonDelegate
extension ViewController: WWFloatButtonDelegate {
    
    func currentView(with tag: Int) -> UIView {
        return self.view
    }
    
    func itemButtonImages(with tag: Int) -> [UIImage] {
        let images = [#imageLiteral(resourceName: "plus"), #imageLiteral(resourceName: "power"), #imageLiteral(resourceName: "refresh"), #imageLiteral(resourceName: "play"), #imageLiteral(resourceName: "chart")]
        return images
    }
    
    func itemButton(with tag: Int, didTouched index: Int) {
        let images = [#imageLiteral(resourceName: "desktop_1"), #imageLiteral(resourceName: "desktop_2"), #imageLiteral(resourceName: "desktop_5"), #imageLiteral(resourceName: "desktop_3"), #imageLiteral(resourceName: "desktop_4")]
        myImageView.image = images[safe: index]
    }
    
    func mainButtonStatus(isTouched: Bool, with tag: Int) {
        wwPrint(isTouched)
    }
}
