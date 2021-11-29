//
//  ViewController.swift
//  QRCode
//
//  Created by William.Weng on 2021/11/29.
//

import UIKit
import WWPrint
import AVFoundation

final class ViewController: UIViewController {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeLabel: UILabel!
    
    private let feedback = UIImpactFeedbackGenerator._build(style: .soft)
    private var isFinish = true
    private var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let scanViewController = segue.destination as? ScanViewController else { return }
        scanViewController.configure(types: [.code128, .qr], delegate: self)
    }
}

extension ViewController: ScanDelegate {
    
    func metadataOutput(_ output: AVMetadataMachineReadableCodeObject) {
        
        feedback._impact()
        
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = true
        qrCodeLabel.translatesAutoresizingMaskIntoConstraints = true
        
        if (!isFinish) { return }
        
        UIView.animate(withDuration: 5.0, delay: 0, options: .curveEaseIn) {
            self.qrCodeImageView.image = #imageLiteral(resourceName: "QRCode2")
            self.qrCodeImageView.frame = output.bounds
            self.qrCodeLabel.frame = output.bounds
            self.qrCodeLabel.text = output.stringValue
            self.isFinish = false
        } completion: { isOK in
            self.qrCodeImageView.image = #imageLiteral(resourceName: "QRCode1")
            self.isFinish = true
        }
    }
}

