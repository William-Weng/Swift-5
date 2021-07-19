//
//  Cells.swift
//  UISplitViewController_HelloWorld
//
//  Created by William.Weng on 2020/9/30.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

final class MyCell: UITableViewCell, CellReusable {
    
    typealias PDFInfomation = (title: String, url: String, icon: UIImage)

    static var PDFInfomations: [PDFInfomation] = pdfUrlArray()

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myTitleLabel: UILabel!
    @IBOutlet weak var myCrayonImageView: UIImageView!
    @IBOutlet weak var crayonImageViewWidthConstraint: NSLayoutConstraint!
    
    func configure(with indexPath: IndexPath) {
        
        guard let info = Self.PDFInfomations[safe: indexPath.row] else { return }
        
        myTitleLabel.text = info.title
        myImageView.image = info.icon
    }
}

// MARK: - 小工具
extension MyCell {
    
    /// PDF文件資料 (假資料)
    private static func pdfUrlArray() -> [MyCell.PDFInfomation] {
        
        let array = [
            (title: "iPhone 1", url: "https://devstreaming-cdn.apple.com/videos/wwdc/2018/811tcr2wk13t3uq/811/811_presenting_design_work.pdf", icon: #imageLiteral(resourceName: "icon_1")),
            (title: "iPhone 2", url: "https://devstreaming-cdn.apple.com/videos/wwdc/2017/241iivj8rn2fo3ft0r/241/241_introducing_pdfkit_on_ios.pdf", icon: #imageLiteral(resourceName: "icon_2")),
            (title: "iPhone 3", url: "https://devstreaming-cdn.apple.com/videos/wwdc/2018/227r61xi77ucgjz6zm/227/227_optimizing_app_assets.pdf", icon: #imageLiteral(resourceName: "icon_3")),
            (title: "iPhone 4", url: "https://www.apple.com/tw/business/docs/site/Whats_New_for_Business.pdf", icon: #imageLiteral(resourceName: "icon_4")),
            (title: "iPhone 5", url: "https://devstreaming-cdn.apple.com/videos/wwdc/2017/241iivj8rn2fo3ft0r/241/241_introducing_pdfkit_on_ios.pdf", icon: #imageLiteral(resourceName: "icon_5")),
            (title: "iPhone 6", url: "https://cdn2.hubspot.net/hubfs/2401279/WWDC%2017%20June%202017%20FINAL_.pdf", icon: #imageLiteral(resourceName: "icon_1")),
            (title: "iPhone 7", url: "https://www.apple.com/tw/business/docs/site/Whats_New_for_Business.pdf", icon: #imageLiteral(resourceName: "icon_2")),
            (title: "iPhone 8", url: "https://devstreaming-cdn.apple.com/videos/wwdc/2017/241iivj8rn2fo3ft0r/241/241_introducing_pdfkit_on_ios.pdf", icon: #imageLiteral(resourceName: "icon_3")),
            (title: "iPhone 9", url: "https://cdn2.hubspot.net/hubfs/2401279/WWDC%2017%20June%202017%20FINAL_.pdf", icon: #imageLiteral(resourceName: "icon_4")),
            (title: "iPhone 10", url: "https://devstreaming-cdn.apple.com/videos/wwdc/2017/241iivj8rn2fo3ft0r/241/241_introducing_pdfkit_on_ios.pdf", icon: #imageLiteral(resourceName: "icon_5")),
        ]
        
        return array
    }
}
