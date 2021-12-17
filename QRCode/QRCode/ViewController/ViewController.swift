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
    private var scanViewController: ScanViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let scanViewController = segue.destination as? ScanViewController else { return }
        
        scanViewController.configure(types: [.code128, .qr], delegate: self)
        self.scanViewController = scanViewController
    }
    
    @IBAction func startRunning(_ sender: UIBarButtonItem) {
        scanViewController?.startRunning()
    }
    
    @IBAction func stopRunning(_ sender: UIBarButtonItem) {
        scanViewController?.stopRunning()
    }
}

// MARK: - ScanDelegate
extension ViewController: ScanDelegate {
    
    func metadataOutput(_ result: Result<AVMetadataMachineReadableCodeObject, Error>) {
        
        switch result {
        case .failure(let error): wwPrint(error)
        case .success(let object):
            
            feedback._impact()
            
            qrCodeLabel.text = object.stringValue
            qrCodeImageView.translatesAutoresizingMaskIntoConstraints = true
            qrCodeImageView.frame = object.bounds
            
            switch object.type {
            case .qr:
                qrCodeImageView.image = #imageLiteral(resourceName: "QRCode")
                qrCodeImageView.backgroundColor = .clear
            case .code128:
                qrCodeImageView.image = nil
                qrCodeImageView.backgroundColor = .systemPink
            default: break
            }
        }
    }
}


