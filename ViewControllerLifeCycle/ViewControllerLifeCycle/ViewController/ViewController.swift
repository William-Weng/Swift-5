//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2021/9/15.
//  ~/Library/Caches/org.swift.swiftpm/

import UIKit
import WWPrint

final class ViewController: UIViewController {
    
    // @IBOutlet weak var mySubView: SubView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // removeMySubView()
        addNewSubView()
    }
    
    private func removeMySubView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // self.mySubView.removeFromSuperview()
        }
    }
    
    private func addNewSubView() {
        
        let subview = SubView(frame: self.view.frame)
        self.view.addSubview(subview)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            subview.removeFromSuperview()
        }
    }
}

extension ViewController {
    
    @IBAction func showXibViewController(_ sender: UIBarButtonItem) {
        
        let viewController = ViewControllerXib(nibName: String(describing: ViewControllerXib.self), bundle: nil)
        viewController.view.backgroundColor = .green

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func showStoryboardViewController(_ sender: UIBarButtonItem) {
        
        let viewController = UIStoryboard._instantiateViewController(identifier: "ViewControllerStoryboard")
        viewController.view.backgroundColor = .yellow
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func showSegueViewController(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "StoryboardSegue", sender: nil)
    }
    
    @IBAction func showClassViewController(_ sender: UIBarButtonItem) {
        
        let viewController = ViewControllerClass()
        viewController.view.backgroundColor = .red
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UIStoryboard (static function)
extension UIStoryboard {
    
    /// 由UIStoryboard => ViewController
    /// - Parameters:
    ///   - name: Storyboard的名稱 => Main.storyboard
    ///   - storyboardBundleOrNil: Bundle名稱
    ///   - identifier: ViewController的代號 (記得要寫)
    /// - Returns: T (泛型) => UIViewController
    static func _instantiateViewController<T: UIViewController>(name: String = "Main", bundle storyboardBundleOrNil: Bundle? = nil, identifier: String = String(describing: T.self)) -> T {
        
        let viewController: T
        
        if #available(iOS 13.0, *) {
            viewController = Self(name: name, bundle: storyboardBundleOrNil).instantiateViewController(identifier: identifier) as T
        } else {
            viewController = Self(name: name, bundle: storyboardBundleOrNil).instantiateViewController(withIdentifier: identifier) as! T
        }
        
        return viewController
    }
}
