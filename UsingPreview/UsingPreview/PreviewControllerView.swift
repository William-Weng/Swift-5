//
//  PreviewControllerView.swift
//  UsingPreview
//
//  Created by William.Weng on 2020/1/21.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit
import SwiftUI

// MARK: - UIViewControllerRepresentable
struct ViewControllerView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ViewController

    var identifier = "ViewController"
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerView>) -> ViewController {
        return previewViewController(identifier: identifier)
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<ViewControllerView>) {}
    
    private func previewViewController(identifier: String) -> ViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: identifier) as! ViewController
        return controller
    }
}

// MARK: - PreviewProvider
struct ViewControllerView_Previews: PreviewProvider {
    static var previews: some View { ViewControllerView() }
}
