//
//  SendPopupViewController.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/25/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Geth

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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var gasPrice = 0
    var gasLimit = 0
    var adddress_index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.view.frame)
        
        CWPermissions.authorizeCameraWith { [weak self] (granted) in
            
            if granted
            {
               print(self?.address ?? "")
            }
            else
            {
                CWPermissions.jumpToSystemPrivacySetting()
            }
        }
        
        let popupItem = PopupItem(view: sendPopupView, height: CGFloat(height - 30) , maxWidth: Const.maxWidth, landscapeSize: Const.landscapeSize, popupOption: Const.popupOption)
        configurePopupItem(popupItem)
        
        sendPopupView.closeButtonTapHandler = { [weak self] in
            self?.dismissPopupView(duration: Const.popupDuration, curve: .easeInOut, direction: .bottom) { _ in }
        }
        
        sendPopupView.scanButtonTapHandler = { [weak self] in
            print("scanning ")
            print(self?.address ?? "")
            print("qqStyle")
            
            let vc = QQScanViewController();
            //vc.
            var style = CWScanViewStyle()
            style.anmiationStyle = CWScanViewAnimationStyle.None
            style.colorAngle = UIColor.init(hexString: "#1379DE")
            vc.scanStyle = style
            vc.addressHandler = { [weak self] (result) in
                print(result.strScanned!)
                if result.strScanned?.range(of:"ethereum:") != nil {
                    let split_address = result.strScanned?.components(separatedBy: ":")
                    self?.sendPopupView.toAddress.text = split_address?[1]
                } else {
                    self?.sendPopupView.toAddress.text = result.strScanned
                }
            }
            
            
            self?.present(vc, animated: true, completion: nil)
        }
        
        sendPopupView.selectButtonTapHandler = { [weak self] in
            let alert = UIAlertController(title: "Local Accounts", message: "Please Choose Account To Send Too!", preferredStyle: .actionSheet)
            
            for i in 0 ... ((self?.appDelegate.keyStore.getAccountCount())! - 1) {
                if (i != self?.adddress_index) {
                    do {
                        let address:GethAddress = (try self?.appDelegate.keyStore.getAccount(at: i).getAddress())!;
                        alert.addAction(UIAlertAction(title: address.getHex(), style: .default, handler: { (action) in
                            print(address.getHex())
                            self?.sendPopupView.toAddress.text = address.getHex()
                        }))
                    } catch {
                        
                    }
                }
                
            }
            self?.present(alert, animated: true, completion: nil)
        }
        
        sendPopupView.sendButtonTapHandler = { [weak self] (ammount, toAddress) in
            print("Sending_Address: ", self?.address ?? "")
            print("GasPrice: ", self?.gasPrice ?? "")
            print("GasLimit: ", self?.gasLimit ?? "")
            print("Ammount: ", ammount)
            print("To_Address: ", toAddress)
            
           
            let etherToSend:Double = Ether(ammount).value
            let trans_service = TransactionService.init(core: (self?.appDelegate.core)!, keystore: (self?.appDelegate.keyStore)!, transferType: TransferType.default)
            let trans = TransactionInfo.init(amount: Decimal(etherToSend).toWei(), address: toAddress, contractAddress: toAddress, gasLimit: Decimal((self?.gasLimit)!), gasPrice:Decimal((self?.gasPrice)!))
            trans_service.sendTransactionWithAccount(with: trans, signer: (self?.adddress_index)!, passphrase: "mogilska") { result in
                switch result {
                case .success(let sendedTransaction):
                    let test:GethTransaction = sendedTransaction
                    print(test.getHash().getHex())
                    
                    let alert = UIAlertController(title: "Sent!", message: "Transactions has been submitted! Hash: " + test.getHash().getHex(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self?.present(alert, animated: true)
                    
                    self?.dismissPopupView(duration: Const.popupDuration, curve: .easeInOut, direction: .bottom) { _ in }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        let gasService = GasService(core: appDelegate.core)
        
        gasService.getSuggestedGasPrice() { result in
            switch result {
            case .success(let gasPrice):
                self.gasPrice = Int(gasPrice)
            case .failure(let error):
                print(error)
            }
        }
        
        gasService.getSuggestedGasLimit() { result in
            switch result {
            case .success(let gasLimit):
                self.gasLimit = Int(gasLimit)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func tapPopupContainerView(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended && canTapDismiss {
            dismissPopupView(duration: Const.popupDuration, curve: .easeInOut, direction: .bottom) { _ in }
        }
    }
    
    private func showCompletionView() {
        
    }
}


