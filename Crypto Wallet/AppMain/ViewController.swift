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

class ViewController: UIViewController, SyncCoordinatorDelegate {
    
    @IBOutlet weak var walletHeaderView: UIView!
    @IBOutlet weak var walletView: WalletView!
    
    @IBOutlet weak var addCardViewButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let keystore = KeystoreService()
    
    var tempcard: ColoredCardView!
    
    var wallets = [ColoredCardView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        walletView.walletHeader = walletHeaderView
        
        walletView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        //print(keystore.getAccountCount())
        
        print((keystore.getAccountCount() - 1))
        
        for i in 0 ... (keystore.getAccountCount() - 1) {
            let wallet = ColoredCardView.nibForClass()
            //wallet.update(index: i)
            wallets.append(wallet)
        }
        
        
        walletView.reload(cardViews: wallets)
        
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
        print("Receive Transactions: ", transactions)
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        
        for i in 0 ... (keystore.getAccountCount() - 1) {
            wallets[i].update(index: i)
        }
        
        //walletView.insert(cardView: ColoredCardView.nibForClass(), animated: true, presented: true)
        /*print("Create Wallet")
        let kstore = KeystoreService()
        do {
            try kstore.createAccount(passphrase: "mogilska")
        } catch {
            
        }*/
        
        
        /*
        let chain = Chain.ropsten
        
        //let core = Ethereum.core
        let keystore = KeystoreService()
        let core = Ethereum.core
        core.chain = chain
        let syncCoordinator = StandardSyncCoordinator()
        core.syncCoordinator = syncCoordinator
        
        do  {
            print(try keystore.getAccount(at: 0).getAddress().getHex())

            try syncCoordinator.startSync(chain: chain, delegate: self)
            try core.client = syncCoordinator.getClient()
        } catch {
            
        }*/
        
        let amount = Ether.init("1.0")
        print(amount.raw.toWei())
        //20000000000000000.0
        //1000000000000000000
        
        /*
        let trans_service = TransactionService.init(core: core, keystore: keystore, transferType: TransferType.default)
        let trans = TransactionInfo.init(amount: 20000000000000000.0, address: "0x697baf1c1c441ad4ed98c1b9c73f4f409991887a", contractAddress: "0x697baf1c1c441ad4ed98c1b9c73f4f409991887a", gasLimit: 53000.0, gasPrice: 1000000000.0)
        trans_service.sendTransaction(with: trans, passphrase: "mogilska") { result in
            switch result {
            case .success(let sendedTransaction):
                print(sendedTransaction)
            case .failure(let error):
                print(error)
            }
        }
        
       let gasService = GasService(core: core)
        
        gasService.getSuggestedGasPrice() { result in
            switch result {
            case .success(let gasPrice):
                print("gasPrice: ", gasPrice)
            case .failure(let error):
                print(error)
            }
        }
        
        gasService.getSuggestedGasLimit() { result in
            switch result {
            case .success(let gasLimit):
                print("gasLimit: ", gasLimit)
            case .failure(let error):
                print(error)
            }
        }
        */
       /*
        let chain = Chain.ropsten

        let keystore = KeystoreService()
        let core = Ethereum.core
        core.chain = chain
        let syncCoordinator = StandardSyncCoordinator()
        core.syncCoordinator = syncCoordinator
        
        do  {
            try syncCoordinator.startSync(chain: chain, delegate: self)
            try core.client = syncCoordinator.getClient()
            let account:GethAccount = try keystore.createAccount(passphrase: "mogilska")
            print(account.getAddress().getHex())
        } catch {
            let nsError = error as NSError
            print(nsError.localizedDescription)
        }
        */
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

