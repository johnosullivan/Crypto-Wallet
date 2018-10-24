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
    }
    
    func waitForStatusChangeWithHash(hash: String) {
        
    }
    
    func didRecieveTxDone(notification:Notification) -> Void {
      
    }
    
    func receivePresention(notification:Notification) -> Void {
    
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
    
    func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
