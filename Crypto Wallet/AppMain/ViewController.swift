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
import UserNotifications

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
    
    private var loadingNotificationBar: NotificationBar?
    private var isNotificationVisible = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    let data :[[String]] = [
        ["Date","From/To","Account"],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","+1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","+2.3" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","-1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","-0.5" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","+1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","+2.3" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","-1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","-0.5" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","+1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","+2.3" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","-1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","-0.5" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","+1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","+2.3" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","-1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","-0.5" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","+1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","+2.3" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","-1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","-0.5" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","+1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","+2.3" ],
        ["10/21/2018","0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106","-1.0" ],
        ["10/21/2018","0xd428163A725997a8ccE7AaD8c2422fB0cBec4def","-0.5" ]
    ]
    
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
        var status:Int = 0
        DispatchQueue.global(qos: .background).async {
            var break_loop = true
            while(break_loop) {
                print("Waiting...", hash)
                do {
                    let hash:GethHash = GethHash.init(fromHex: hash)
                    let receipt: GethReceipt = try self.appDelegate.core.client.getTransactionReceipt(self.appDelegate.core.context, hash: hash)
                    status = Int(receipt.string()!.components(separatedBy: " ")[0].components(separatedBy: "=")[1])!
                    break_loop = false
                    group.leave()
                } catch { break_loop = true }
                sleep(1)
            }
        }
        group.notify(queue: .main) {
            NotificationCenter.default.post(name:.txDone, object: nil, userInfo: ["hash": hash, "status": status])
            self.refreshWallets()
        }
    }
    
    func didRecieveTxDone(notification:Notification) -> Void {
      
        
        let hash = notification.userInfo!["hash"]! as! String
        let status = notification.userInfo!["status"]! as! Int
        print("hash: ", hash)
        print("status: ", status)
        if (status == 1) {
            /*let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Transaction Successful!"
            content.body = hash
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,  repeats: false)
            let identifier = "CWLocalNotification"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    // Something went wrong
                }
            })*/
        } else {
          
        }
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
            
            wallet.collectionView.tabularDelegate = self
            wallet.collectionView.tabularDatasource = self
            wallet.collectionView.reloadData()
            

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
      
        NotificationCenter.default.post(name:.txDone, object: nil, userInfo: ["hash": "dafgssgdgfsfdg", "status": 1])
        
        self.appDelegate.getTransactions(address: "0x5CAf1a91Ae54e76B6b5e6Aa656e8693FbB10c106", result: { result in
            switch result {
            case .success(let results):
                for item in results {
                    print("-------------------------------------------------------------------------------------------")
                    print("FROM: " + item.from + " -> TO: " + item.to)
                    print("ACCOUNT: " + item.amount.amount + " - HASH: " + item.txHash)
                }
            case .failure(let error):
                print(error)
            }
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

// MARK: - TabularCollectionDataSource

extension ViewController: TabularCollectionDataSource {
    
    func tabularView(_ tabularView: TabularCollectionView, titleAttributesForCellAt indexpath: IndexPath) -> CellTitleAttributes {
        var font = Font.avenirLight.font()
        var textAlignment = NSTextAlignment.center
        if indexpath.section == 0 {
            font = Font.avenirLight.font(ofSize: 12)
        }
        if indexpath.row < 2 && indexpath.section != 0 {
            textAlignment = .right
        }
        let text = data[indexpath.section][indexpath.row]
        return CellTitleAttributes(title: text, font: font, textAlignment: textAlignment, textColor: Color.text.uiColor)
    }
    
    func numberOfColumns(in tabularView: TabularCollectionView) -> Int { return data.first?.count ?? 0 }
    
    func numberOfRows(in tabularView: TabularCollectionView) -> Int { return data.count }
    
    func numberOfStaticRows(in tabularView: TabularCollectionView) -> Int { return 1 }
    
    func numberOfStaticColumn(in tabularView: TabularCollectionView) -> Int { return 1 }
    
}

// MARK: - TabularCollectionDelegate

extension ViewController: TabularCollectionDelegate {
    
    private func tabularView(_ tabularView: TabularCollectionView, didSeletItemAt indexPath: IndexPath) { }
    
    func tabularView(_ tabularView: TabularCollectionView, shouldHideColumnSeparatorAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
}


