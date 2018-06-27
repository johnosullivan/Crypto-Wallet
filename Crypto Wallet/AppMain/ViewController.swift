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

    
    var wallets = [WalletCardView]()
    var refreshTimer: Timer?
    let rate = RatesNetworkService()
    
    func sendPresention(notification:Notification) -> Void {
        print("sendPresention")
        let address = notification.userInfo!["address"]! as! String
        let index = notification.userInfo!["index"]! as! Int
        print(address)
        let popup = SendPopupViewController()
        popup.adddress_index = index
        popup.height = Double((self.view.window?.frame.height)!)
        popup.address = address
        PopupWindowManager.shared.changeKeyWindow(rootViewController: popup)
        
    }
    
    func receivePresention(notification:Notification) -> Void {
        print("receivePresention")
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReceivingViewController") as! ReceivingViewController
        //self.present(vc, animated: true, completion: nil)
        let address = notification.userInfo!["address"]! as! String
        //let index = notification.userInfo!["index"]! as! Int
        print(address)
        let popup = ReceivedPopupViewController()
        popup.address = address
        PopupWindowManager.shared.changeKeyWindow(rootViewController: popup)
    }
    
    func getBalanceOfAddress(address: GethAccount, handler: ((_ balance: String) -> Void)?) {
        var ethBalance = Ether(weiString: "0.0")
        let address = address.getAddress().getHex()
        appDelegate.getBalance(address: address!) { result in
            switch result {
            case .success(let balance):
                ethBalance.update(weiString: balance)
                handler!(ethBalance.symbol + " " + String(ethBalance.value))
            case .failure(let error):
                print(error)
                handler!(ethBalance.symbol + " " + String(ethBalance.value))
            }
        }
    }
    
    func getRateConvert(from: String, to: String, handler: ((_ balance: Double) -> Void)?) {
        rate.getRate(currencies: Constants.Wallet.SupportedCurrencies) { result in
            switch result {
            case .success(let rates):
                let rate_array = rates.filter { $0.from == from }
                for index in 0...rate_array.count - 1 {
                    let current:Rate = rate_array[index]
                    if (current.to == to) {  handler!(current.value) }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        walletView.walletHeader = walletHeaderView
        walletView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:.send, object:nil, queue:nil, using:sendPresention)
        nc.addObserver(forName:.receive, object:nil, queue:nil, using:receivePresention)
        
        var currentRate:Double = 0.0
        
        self.getRateConvert(from: "ETH", to: "USD", handler: { (rate: Double) in
            currentRate = rate
        })
        
        for i in 1 ... appDelegate.keyStore.getAccountCount() {
            let wallet = WalletCardView.nibForClass()
            wallet.currentIndex = (i - 1)
            do {
                let addressGeth: GethAccount = try appDelegate.keyStore.getAccount(at: (i - 1))
                wallet.currentAddress = addressGeth.getAddress().getHex()!
                print(addressGeth.getAddress().getHex()!)
                self.getBalanceOfAddress(address: addressGeth, handler: { (balance: String) in
                    wallet.currentBalance = balance
                })
            } catch { print(error as Error) }
            wallets.append(wallet)
        }
        
        walletView.reload(cardViews: wallets)
        walletView.didUpdatePresentedCardViewBlock = { [weak self] (_) in
            self?.showAddCardViewButtonIfNeeded()
            self?.addCardViewButton.addTransitionFade()
        }
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { (timer) in
            self.refreshWallets()
        }
    }
    
    func refreshWallets() {
        for i in 1 ... appDelegate.keyStore.getAccountCount() {
            do {
                let addressGeth: GethAccount = try appDelegate.keyStore.getAccount(at: (i - 1))
                wallets[(i - 1)].currentAddress = addressGeth.getAddress().getHex()!
                self.getBalanceOfAddress(address: addressGeth, handler: { (balance: String) in
                    self.wallets[(i - 1)].currentBalance = balance
                })
            } catch { print(error as Error) }
        }
    }
    
    func showAddCardViewButtonIfNeeded() {
        addCardViewButton.alpha = walletView.presentedCardView == nil || walletView.insertedCardViews.count <= 1 ? 1.0 : 0.0
    }
    
    func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        
        self.getRateConvert(from: "ETH", to: "USD", handler: { (rate: Double) in
            print(rate)
        })
        /*
        do {
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

