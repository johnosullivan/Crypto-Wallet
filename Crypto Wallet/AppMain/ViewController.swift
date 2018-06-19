//
//  ViewController.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/11/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit
import Geth
import RealmSwift

class Account: Object {
    @objc dynamic var name = ""
    @objc dynamic var address = ""
}

class ViewController: UIViewController {
    
    @IBOutlet weak var walletHeaderView: UIView!
    @IBOutlet weak var walletView: WalletView!
    
    @IBOutlet weak var addCardViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        walletView.walletHeader = walletHeaderView
        
        walletView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        let coloredCardViews = [ColoredCardView]()
        /*
         for index in 1...10 {
         let cardView = ColoredCardView.nibForClass()
         cardView.index = index
         coloredCardViews.append(cardView)
         }
         */
        walletView.reload(cardViews: coloredCardViews)
        
        walletView.didUpdatePresentedCardViewBlock = { [weak self] (_) in
            self?.showAddCardViewButtonIfNeeded()
            self?.addCardViewButton.addTransitionFade()
        }
        
        /*let acc = Account()
        acc.address = ""
        acc.name = ""
        
        let realm = try! Realm()

        try! realm.write {
            realm.add(acc)
        }
        
        let accs = realm.objects(Account.self).filter("name == ''")
        print(accs)*/

        
    }
    
    func showAddCardViewButtonIfNeeded() {
        addCardViewButton.alpha = walletView.presentedCardView == nil || walletView.insertedCardViews.count <= 1 ? 1.0 : 0.0
    }
    
     func syncDidChangeProgress(current: Int64, max: Int64) {
        
    }
    func syncDidFinished() {
        
    }
    func syncDidUpdateBalance(_ balanceHex: String, timestamp: Int64) {
        
    }
    func syncDidUpdateGasLimit(_ gasLimit: Int64) {
        
    }
    func syncDidReceiveTransactions(_ transactions: [GethTransaction], timestamp: Int64) {
        
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        
        //walletView.insert(cardView: ColoredCardView.nibForClass(), animated: true, presented: true)
        print("Send transaction")
        
        /*
        let chain = Chain.ropsten
        
        let context: GethContext = GethNewContext()
        var error: NSError?
        let client =  GethNewEthereumClient(chain.clientUrl, &error)
      
        let receiverAddress = "0x697baf1c1c441ad4ed98c1b9c73f4f409991887a"
        let gethAddress = GethNewAddressFromHex(receiverAddress, &error)
        let noncePointer: Int64 = 5
        
        /*let gaddress = GethAddress.init(fromHex: "0x51e003aeb3feb22093528f0c6fc046c498e2d8d3")
        do  {
            try client?.getNonceAt(context, account: gaddress, number: -1, nonce: &noncePointer)
        } catch {
            
        }*/
        print(noncePointer)
        
        let gasPrice:Decimal = 0.0
        //let gasLimit:Decimal = 0.0
        let account:Decimal = 0.0
        
        let intAmount = GethNewBigInt(0)
        intAmount?.setString(account.toHex(), base: 16)
        //let gethGasLimit = GethNewBigInt(0)
        //gethGasLimit?.setString(gasLimit.toHex(), base: 16)
        let gethGasPrice = GethNewBigInt(0)
        gethGasPrice?.setString(gasPrice.toHex(), base: 16)
        
        
        var gethGasLimit: Int64 = 500000000000

        
        let trans:GethTransaction = GethNewTransaction(noncePointer, gethAddress, intAmount, gethGasLimit, gethGasPrice, nil)
        
        
        */
        /*let intAmounst = GethNewBigInt(0)
        intAmount?.setString(info.amount.toHex(), base: 16)
        
        let gethGasLimit = GethNewBigInt(0)
        gethGasLimit?.setString(info.gasLimit.toHex(), base: 16)
        let gethGasPrice = GethNewBigInt(0)
        gethGasPrice?.setString(info.gasPrice.toHex(), base: 16)*/
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

