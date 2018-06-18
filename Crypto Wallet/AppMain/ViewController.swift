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
        
        let acc = Account()
        acc.address = ""
        acc.name = ""
        
        let realm = try! Realm()

        try! realm.write {
            realm.add(acc)
        }
        
        let accs = realm.objects(Account.self).filter("name == ''")
        print(accs)

        
    }
    
    func showAddCardViewButtonIfNeeded() {
        addCardViewButton.alpha = walletView.presentedCardView == nil || walletView.insertedCardViews.count <= 1 ? 1.0 : 0.0
    }
    
    @IBAction func addCardViewAction(_ sender: Any) {
        
        walletView.insert(cardView: ColoredCardView.nibForClass(), animated: true, presented: true)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}

