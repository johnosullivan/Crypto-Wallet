//
//  ReceivingViewController.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/24/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

class ReceivingViewController: UIViewController {
    
    @IBOutlet weak var qrimageview: UIImageView!
    @IBOutlet weak var address: UILabel!

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //qrimageview.image = generateQRCode(from: "0xFe006D8454e40C53Fa9d9e8878260b7081Ad6ce5")
        address.text = "0xFe006D8454e40C53Fa9d9e8878260b7081Ad6ce5"
    }
    
    @IBAction func done(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
}
