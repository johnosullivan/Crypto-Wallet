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
    static let txDone = Notification.Name("txDone")
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
        let address = notification.userInfo!["address"]! as! String
        let index = notification.userInfo!["index"]! as! Int
        let popup = SendPopupViewController()
        popup.adddress_index = index
        popup.height = Double((self.view.window?.frame.height)!)
        popup.address = address
        popup.receivedGethHash = { [weak self] (hash) in
            self?.waitForStatusChangeWithHash(hash: hash)
        }
        PopupWindowManager.shared.changeKeyWindow(rootViewController: popup)
    }
    
    func waitForStatusChangeWithHash(hash: String) {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            var break_loop = true
            while(break_loop) {
                do {
                    let hash:GethHash = GethHash.init(fromHex: hash)
                    let receipt: GethReceipt = try self.appDelegate.core.client.getTransactionReceipt(self.appDelegate.core.context, hash: hash)
                    let status:Int = Int(receipt.string()!.components(separatedBy: " ")[0].components(separatedBy: "=")[1])!
                    break_loop = false
                    NotificationCenter.default.post(name:.txDone, object: nil, userInfo: ["hash": hash.getHex(), "status": status])
                    group.leave()
                } catch { break_loop = true }
                sleep(1)
            }
        }
        group.notify(queue: .main) {
            //self.refreshWallets()
        }
    }
    
    func didRecieveTxDone(notification:Notification) -> Void {
        let hash = notification.userInfo!["hash"]! as! String
        let status = notification.userInfo!["status"]! as! Int
        print("hash: ", hash)
        print("status: ", status)
    }
    
    func receivePresention(notification:Notification) -> Void {
        let address = notification.userInfo!["address"]! as! String
        let popup = ReceivedPopupViewController()
        popup.address = address
        PopupWindowManager.shared.changeKeyWindow(rootViewController: popup)
    }
    
    func getBalanceOfAddress(address: GethAccount, handler: ((_ balance: String, _ value: Double) -> Void)?) {
        var ethBalance = Ether(weiString: "0.0")
        let address = address.getAddress().getHex()
        appDelegate.getBalance(address: address!) { result in
            switch result {
            case .success(let balance):
                ethBalance.update(weiString: balance)
                handler!(ethBalance.symbol + " " + String(ethBalance.value), ethBalance.value)
            case .failure(let error):
                print(error)
                handler!(ethBalance.symbol + " " + String(ethBalance.value), ethBalance.value)
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
        nc.addObserver(forName:.txDone, object:nil, queue:nil, using:didRecieveTxDone)
        
        
        
        for i in 1 ... appDelegate.keyStore.getAccountCount() {
            let wallet = WalletCardView.nibForClass()
            wallet.currentIndex = (i - 1)
            do {
                let addressGeth: GethAccount = try appDelegate.keyStore.getAccount(at: (i - 1))
                wallet.currentAddress = addressGeth.getAddress().getHex()!
                print(addressGeth.getAddress().getHex()!)
                self.getBalanceOfAddress(address: addressGeth, handler: { (balance: String, value: Double) in
                    wallet.currentBalance = balance
                    wallet.etherAmount = value
                })
            } catch { print(error as Error) }
            wallets.append(wallet)
        }
        
        self.getRateConvert(from: "ETH", to: "USD", handler: { (rate: Double) in
            for i in 0 ... self.wallets.count - 1 {
                self.wallets[i].rateAmount = rate
            }
        })
        
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
                self.getBalanceOfAddress(address: addressGeth, handler: { (balance: String, value: Double) in
                    self.wallets[(i - 1)].currentBalance = balance
                    self.wallets[(i - 1)].etherAmount = value
                })
            } catch { print(error as Error) }
        }
        self.getRateConvert(from: "ETH", to: "USD", handler: { (rate: Double) in
            for i in 0 ... self.wallets.count - 1 {
                self.wallets[i].rateAmount = rate
            }
        })
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
        
        do {
            /*
            let rec: GethReceipt = try self.appDelegate.core.client.getTransactionReceipt(self.appDelegate.core.context, hash: GethHash.init(fromHex: "0x3e6a0c0517852dfd243e29c816228d60cbeb071c9f20a15ebcac69db2eb96435"))
            print("rec: ", rec)
            print("getPostState: ", rec.getPostState())
            print("getCumulativeGasUsed: ", rec.getCumulativeGasUsed())
            print("getBloom: ", rec.getBloom().getHex())
            print("getTxHash: ", rec.getTxHash().getHex())*/
            //let rec: GethTransaction = try self.appDelegate.core.client.getTransactionByHash(self.appDelegate.core.context, hash: GethHash.init(fromHex: "0x3e6a0c0517852dfd243e29c816228d60cbeb071c9f20a15ebcac69db2eb96435"))
            //print("rec: ", rec.get)
            //let s:GethSyncProgress = try self.appDelegate.core.client.syncProgress(self.appDelegate.core.context)
            //print(s.getHighestBlock())
            
            let hash:GethHash = GethHash.init(fromHex: "0x633e24c5d0cd3125229a7ef5311c7fc6f0fe9432993eb57cd058056469911ddc")
            let receipt: GethReceipt = try self.appDelegate.core.client.getTransactionReceipt(appDelegate.core.context, hash: hash)
            let status:Int = Int(receipt.string()!.components(separatedBy: " ")[0].components(separatedBy: "=")[1])!
            
            print(status)
         
            
            
            let group = DispatchGroup()
            group.enter()
        
            DispatchQueue.main.async {
                
                var break_loop = true
                
                while(break_loop) {
                    print("looping")
                    do {
                        let hash:GethHash = GethHash.init(fromHex: "0xe7d17c5d5633f2bddbff7d7f2afdb6ce17e7c3fdf11999cc877b764f05d34fae")
                        let receipt: GethReceipt = try self.appDelegate.core.client.getTransactionReceipt(self.appDelegate.core.context, hash: hash)
                        let status:Int = Int(receipt.string()!.components(separatedBy: " ")[0].components(separatedBy: "=")[1])!
                        print("status: ", status)
                        break_loop = false
                        group.leave()
                    } catch {
                        break_loop = true
                    }
                    sleep(1)
                }
                
                
                
                
            }
            
            // does not wait. But the code in notify() gets run
            // after enter() and leave() calls are balanced
            
            group.notify(queue: .main) {
                print("done with async")
            }
            
            
            

            
            
        } catch {
            print(error as Error)
        }
        
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

