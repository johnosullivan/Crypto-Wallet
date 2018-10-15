//
//  Ethereum.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/18/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Geth

protocol EthereumCoreProtocol {
    func start(chain: Chain, delegate: SyncCoordinatorDelegate) throws
}

class Ethereum: EthereumCoreProtocol {
    
    static let core = Ethereum()
    static let syncQueue = DispatchQueue(label: "com.ethereum-wallet.sync")
    
    public let context: GethContext = GethNewContext()
    var syncCoordinator: SyncCoordinatorProtocol!
    var client: GethEthereumClient!
    var chain: Chain!
    
    private init() {}
    
    func start(chain: Chain, delegate: SyncCoordinatorDelegate) throws {
        try syncCoordinator.startSync(chain: chain, delegate: delegate)
        self.client = try syncCoordinator.getClient()
        self.chain = chain
    }
    
}
