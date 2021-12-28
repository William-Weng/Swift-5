//
//  ViewControllerXib.swift
//  Example
//
//  Created by William.Weng on 2021/12/27.
//

import UIKit
import WWPrint

final class ViewControllerXib: UIViewController {

    @IBOutlet weak var myLabel: UILabel!
    
    override init(nibName: String?, bundle: Bundle?) { super.init(nibName: nibName, bundle: bundle); wwPrint("") }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); wwPrint("") }
    
    override func awakeFromNib() { super.awakeFromNib(); wwPrint("") }
    override func loadView() { super.loadView(); wwPrint("") }
    override func viewDidLoad() { super.viewDidLoad(); wwPrint("") }
    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); wwPrint("") }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); wwPrint("") }
    
    override func loadViewIfNeeded() { super.loadViewIfNeeded(); wwPrint("") }
    override func setNeedsFocusUpdate() { super.setNeedsFocusUpdate(); wwPrint("") }
    override func updateViewConstraints() { super.updateViewConstraints(); wwPrint("") }
    
    override func viewWillLayoutSubviews() { super.viewWillLayoutSubviews(); wwPrint("") }
    override func viewDidLayoutSubviews() { super.viewDidLayoutSubviews(); wwPrint("") }
    
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); wwPrint("") }
    override func viewDidDisappear(_ animated: Bool) { super.viewDidDisappear(animated); wwPrint("") }
    
    deinit { wwPrint("") }
}
