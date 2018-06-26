//
//  SendPopupView.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/25/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

class SendPopupView: UIView, PopupViewContainable, Nibable  {
    
    @IBOutlet weak var qrimageview: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var sendview: UIView!
    
    
    var addressStr: String = "" {
        didSet {
            //address.text = addressStr
        }
    }
    
    var qrimage: UIImage? = nil {
        didSet {
            //qrimageview.image = qrimage
        }
    }
    
    enum Const {
        static let height: CGFloat = 300
    }
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setImage(UIImage(named:"close"), for: .normal)
            closeButton.imageView?.tintColor = .gray
        }
    }
    
    var registerButtonTapHandler: (() -> Void)?
    var closeButtonTapHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.backgroundColor()
        sendview.backgroundColor = UIColor.backgroundColor()
        addDropShadow(type: .dynamic, color: .black, opacity: 0.5, radius: 3, shadowOffset: CGSize(width: 0, height: 5))
    }
    
    @IBAction func didTapRegisterButton() {
        registerButtonTapHandler?()
    }
    
    @IBAction func didTapCloseButton() {
        closeButtonTapHandler?()
    }
}

