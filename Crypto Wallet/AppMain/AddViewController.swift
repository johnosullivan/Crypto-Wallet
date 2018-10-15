//
//  AddViewController.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 10/13/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

class AddViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func generateWallet(sender: UIButton) {
        let addGenerateVC = self.storyboard?.instantiateViewController(withIdentifier: "addgenerate") as! AddGenerateWallet
        self.navigationController?.pushViewController(addGenerateVC, animated: true)
    }
    
    @IBAction func importWallet(sender: UIButton) {
       
    }
    
}
