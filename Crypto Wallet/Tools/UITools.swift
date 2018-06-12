//
//  UITools.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/11/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

protocol ShadowHidable: class {
    var shadowImage: UIImage! { get set }
}

extension ShadowHidable where Self: UIViewController {
    
    func showNavBarSeparator(_ show: Bool) {
        if show {
            navigationController?.navigationBar.shadowImage = shadowImage
        } else {
            shadowImage = navigationController?.navigationBar.shadowImage
            navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    
}
