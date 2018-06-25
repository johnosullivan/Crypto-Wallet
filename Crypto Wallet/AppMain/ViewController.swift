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

extension Notification.Name {
    static let send = Notification.Name("send")
    static let receive = Notification.Name("receive")
}

class ViewController: UIViewController {
    
    @IBOutlet weak var walletHeaderView: UIView!
    @IBOutlet weak var walletView: WalletView!
    @IBOutlet weak var addCardViewButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    var wallets = [ColoredCardView]()
    
    func sendPresention(notification:Notification) -> Void {
        print("sendPresention")
    }
    
    func receivePresention(notification:Notification) -> Void {
        print("receivePresention")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingViewController") as! ReceivingViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        walletView.walletHeader = walletHeaderView
        walletView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:.send, object:nil, queue:nil, using:sendPresention)
        nc.addObserver(forName:.receive, object:nil, queue:nil, using:receivePresention)
        
        for i in 0 ... (appDelegate.keyStore.getAccountCount() - 1) {
            let wallet = ColoredCardView.nibForClass()
            wallet.update(index: i)
            wallets.append(wallet)
        }
        
        walletView.reload(cardViews: wallets)
        walletView.didUpdatePresentedCardViewBlock = { [weak self] (_) in
            self?.showAddCardViewButtonIfNeeded()
            self?.addCardViewButton.addTransitionFade()
        }
    
    }
    
    func showAddCardViewButtonIfNeeded() {
        addCardViewButton.alpha = walletView.presentedCardView == nil || walletView.insertedCardViews.count <= 1 ? 1.0 : 0.0
    }
    
    func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        
        
        
        
        /*do {
            try appDelegate.keyStore.createAccount(passphrase: "mogilska")
        } catch {
            
        }*/
        /*let rate = RatesNetworkService()
         let currencies_array = ["ETH","USD"]
         rate.getRate(currencies: currencies_array) { result in
         switch result {
         case .success(let rates):
         let rate_array = rates.filter { $0.from == "ETH" }
         for index in 0...rate_array.count - 1 {
         let current:Rate = rate_array[index]
         if (current.to == "USD") {
         self.rateBalanceLabel.text = "$" + String(Double(ethBalance.value) * current.value)
         }
         }
         case .failure(let error):
         print(error)
         }
         }*/
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

