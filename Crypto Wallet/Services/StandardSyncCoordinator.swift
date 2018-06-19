//
//  StandardSyncCoordinator.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/19/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import Geth

protocol SyncCoordinatorProtocol {
    func startSync(chain: Chain, delegate: SyncCoordinatorDelegate) throws
    func getClient() throws -> GethEthereumClient
}

protocol SyncCoordinatorDelegate: class {
    func syncDidChangeProgress(current: Int64, max: Int64)
    func syncDidFinished()
    func syncDidUpdateBalance(_ balanceHex: String, timestamp: Int64)
    func syncDidUpdateGasLimit(_ gasLimit: Int64)
    func syncDidReceiveTransactions(_ transactions: [GethTransaction], timestamp: Int64)
}


class StandardSyncCoordinator: SyncCoordinatorProtocol {
    
    private var chain: Chain!
    
    func startSync(chain: Chain, delegate: SyncCoordinatorDelegate) throws {
        self.chain = chain
        delegate.syncDidFinished()
    }
    
    func getClient() throws -> GethEthereumClient {
        var error: NSError?
        let client =  GethNewEthereumClient(chain.clientUrl, &error)
        guard error == nil else {
            throw error!
        }
        return client!
    }
    
}
