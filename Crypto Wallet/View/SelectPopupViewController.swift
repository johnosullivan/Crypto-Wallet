//
//  SelectPopupViewController.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/26/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Geth

class SelectPopupViewController: UIViewController {
  
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var gasPrice = 0
    var gasLimit = 0
    var adddress_index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.view.frame)
     
    }
    
    private func showCompletionView() {
        
    }
}
