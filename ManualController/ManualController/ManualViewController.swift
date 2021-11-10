//
//  ManualViewController.swift
//  ManualViewController
//
//  Created by William.Weng on 2021/11/11.
//

import UIKit

final class ManualViewController: UIPageViewController {

    let controllers = [
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController,
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController,
    ]
        
//    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
//        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: options)
//    }

//    required init?(coder: NSCoder) {
//
//        // [用Code寫的話，長這樣子… + self.isDoubleSided = true + setViewControllers(兩頁)](https://itnext.io/ios-uipageviewcontroller-easy-dd559c51ffa)
//        let options: [UIPageViewController.OptionsKey : Any] = [
//            .spineLocation: UIPageViewController.SpineLocation.mid.rawValue,
//            .interPageSpacing: 30.0,
//        ]
//
//        super.init(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: options)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        // self.isDoubleSided = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var viewControllerList: [ViewController] = [controllers.first!]
        
        switch spineLocation {
        case .none: print("none")
        case .max: print("max")
        case .min: print("min")
        case .mid: viewControllerList = [controllers.first!, controllers.last!]     // 一定要兩頁，不然會閃退
        @unknown default: fatalError()
        }
        
        setViewControllers(viewControllerList, direction: .forward, animated: true, completion: nil)
    }
}

extension ManualViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.configure(with: UIColor._random())
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.configure(with: UIColor._random())
        return vc
    }
}

// MARK: - UIColr (static function)
extension UIColor {
    
    /// 隨機顏色
    /// - Returns: UIColor
  static func _random() -> UIColor { return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)}
}
