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

import web3swift

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
    
    @IBAction func add(sender: UIButton) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL , includingPropertiesForKeys: nil)
            // process files
            print(fileURLs)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
            let address = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")!
            let web3Main = Web3.InfuraRinkebyWeb3(accessToken: "")
            let balanceResult = web3Main.eth.getBalance(address: address)
            guard case .success(let balance) = balanceResult else { return }
            print("balance: ", balance)
        
    }
    
    func waitForStatusChangeWithHash(hash: String) {
        
    }
    
    func didRecieveTxDone(notification:Notification) -> Void {
      
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
        //addCardViewButton.alpha = walletView.presentedCardView == nil || walletView.insertedCardViews.count <= 1 ? 1.0 : 0.0
    }
    
    func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        
       /*
        do {
            try appDelegate.keyStore.createAccount(passphrase: "mogilska")
        } catch {
            
        }
 */
        /*
        
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
 
        */
        
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
/*
extension ViewController: TabularCollectionDataSource {
    
    func tabularView(_ tabularView: TabularCollectionView, titleAttributesForCellAt indexpath: IndexPath) -> CellTitleAttributes {
        var font = Font.avenirMedium.font()
        var textAlignment = NSTextAlignment.center
        if indexpath.section == 0 {
            font = Font.avenirMedium.font(ofSize: 12)
        }
        if indexpath.row == 0 && indexpath.section != 0 {
            textAlignment = .center
        }
        if indexpath.row == 1 && indexpath.section != 0 {
            textAlignment = .left
        }
        if indexpath.row == 2 && indexpath.section != 0 {
            textAlignment = .center
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
*/

