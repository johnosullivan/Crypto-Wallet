//
//  SendPopupViewController.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/25/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

class SendPopupViewController: BasePopupViewController {
    
    enum Const {
        static let popupDuration: TimeInterval = 0.3
        static let transformDuration: TimeInterval = 0.4
        static let maxWidth: CGFloat = 500
        static let landscapeSize: CGSize = CGSize(width: maxWidth, height: 249)
        static let popupOption = PopupOption(shapeType: .roundedCornerTop(cornerSize: 8), viewType: .toast, direction: .bottom, canTapDismiss: true)
        static let popupCompletionOption = PopupOption(shapeType: .roundedCornerTop(cornerSize: 8), viewType: .toast, direction: .bottom, hasBlur: false)
    }
    
   
    private let sendPopupView = SendPopupView.view()
    
    public var address = ""
    
    public var height = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.view.frame)
        
        let popupItem = PopupItem(view: sendPopupView, height: CGFloat(height - 30) , maxWidth: Const.maxWidth, landscapeSize: Const.landscapeSize, popupOption: Const.popupOption)
        configurePopupItem(popupItem)
        
        sendPopupView.closeButtonTapHandler = { [weak self] in
            self?.dismissPopupView(duration: Const.popupDuration, curve: .easeInOut, direction: .bottom) { _ in }
        }
        
        var qrCode = QRCode(address)
        qrCode?.color = CIColor(color: UIColor.black)
        qrCode?.backgroundColor = CIColor(color: UIColor.backgroundColor())
        
        
        sendPopupView.qrimage = qrCode?.image
        sendPopupView.addressStr = address
        
        /*sendPopupView.sendButtonTapHandler = { [weak self] in
            guard let me = self else { return }
            me.showCompletionView()
        }*/
    }
    
    override func tapPopupContainerView(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended && canTapDismiss {
            dismissPopupView(duration: Const.popupDuration, curve: .easeInOut, direction: .bottom) { _ in }
        }
    }
    
    private func showCompletionView() {
        
    }
}


