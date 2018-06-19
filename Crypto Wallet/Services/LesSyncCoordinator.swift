//
//  LesSyncCoordinator.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/19/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import Geth

extension Timer {
    
    class func createDispatchTimer(interval: DispatchTimeInterval,
                                   leeway: DispatchTimeInterval,
                                   queue: DispatchQueue,
                                   block: @escaping ()->()) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0),
                                                   queue: queue)
        timer.schedule(deadline: DispatchTime.now(),
                       repeating: interval,
                       leeway: leeway)
        
        // Use DispatchWorkItem for compatibility with iOS 9. Since iOS 10 you can use DispatchSourceHandler
        let workItem = DispatchWorkItem(block: block)
        timer.setEventHandler(handler: workItem)
        timer.resume()
        return timer
    }
}

class LesSyncCoordinator: SyncCoordinatorProtocol {
    
    private let context: GethContext
    private let keystore: KeystoreService
    
    private weak var delegate: SyncCoordinatorDelegate?
    private var node: NodeProtocol!
    
    private var syncTimer: DispatchSourceTimer?
    
    private var isSyncing = false
    private var isSyncingFinished = false
    
    init(context: GethContext, keystore: KeystoreService) {
        self.context = context
        self.keystore = keystore
    }
    
    func startSync(chain: Chain, delegate: SyncCoordinatorDelegate) throws {
        GethSetVerbosity(9)
        
        self.delegate = delegate
        try startNode(chain: chain)
        try startProgressTicks()
        try subscribeNewHead()
    }
    
    func getClient() throws -> GethEthereumClient {
        return try node.ethereumClient()
    }
    
    deinit {
        try? node.stop()
    }
    
    // MARK: - Creating node
    
    private func startNode(chain: Chain) throws {
        self.node = try Node(chain: chain)
        try node.start()
    }
    
    // MARK: - Subscribing on new head
    
    private func subscribeNewHead() throws {
        
        let newBlockHandler = NewHeadHandler(errorHandler: nil) { header in
            do {
                
                guard !self.isSyncing else {
                    return
                }
                
                if !self.isSyncingFinished {
                    self.delegate?.syncDidFinished()
                    self.syncTimer?.cancel()
                    self.syncTimer = nil
                    self.isSyncingFinished = true
                }
                
                let address = try self.keystore.getAccount(at: 0).getAddress()!
                let balance = try self.node.ethereumClient().getBalanceAt(self.context, account: address, number: header.getNumber()) // TODO: change to try! gethClient.getBalanceAt(GethNewContext(), account: address!, number: -1)
                let time = header.getTime()
                
                self.delegate?.syncDidUpdateBalance(balance.getString(16), timestamp: time)
                self.delegate?.syncDidUpdateGasLimit(header.getGasLimit())
                
                let transactions = self.getTransactions(address: address.getHex(), startBlockNumber: header.getNumber(), endBlockNumber: header.getNumber())
                if !transactions.isEmpty {
                    self.delegate?.syncDidReceiveTransactions(transactions, timestamp: time)
                }
            } catch {}
        }
        try node.ethereumClient().subscribeNewHead(context, handler: newBlockHandler, buffer: 16)
    }
    
    
    // MARK: - Synchronization status
    
    private func startProgressTicks() throws {
        syncTimer = Timer.createDispatchTimer(interval: .seconds(1), leeway: .seconds(0), queue: Ethereum.syncQueue) {
            self.timerTick()
        }
    }
    
    private func timerTick() {
        if let syncProgress = try? node.ethereumClient().syncProgress(context) {
            let currentBlock = syncProgress.getCurrentBlock()
            let highestBlock = syncProgress.getHighestBlock()
            delegate?.syncDidChangeProgress(current: currentBlock, max: highestBlock)
            isSyncing = true
        } else if isSyncing {
            isSyncing = false
        }
    }
    
    /// Retrive account connected transactions for defined blocks.
    /// VERY Resource-intensive operation.
    ///
    /// - Parameters:
    ///   - address: Ethereum address
    ///   - startBlockNumber: Search start block
    ///   - endBlockNumber: Search end block number
    /// - Returns: Array of GethTransactions
    private func getTransactions(address: String, startBlockNumber: Int64, endBlockNumber: Int64) -> [GethTransaction] {
        
        var transactions = [GethTransaction]()
        for blockNumber in startBlockNumber...endBlockNumber {
            let block = try! node.ethereumClient().getBlockByNumber(context, number: blockNumber)
            let blockTransactions = block.getTransactions()!
            
            for index in 0...blockTransactions.size()  {
                guard let transaction = try? blockTransactions.get(index) else {
                    continue
                }
                
                let from = try? node.ethereumClient().getTransactionSender(context, tx: transaction, blockhash: block.getHash(), index: index)
                let to = transaction.getTo()
                
                if to?.getHex() == address || from?.getHex() == address {
                    transactions.append(transaction)
                }
            }
        }
        return transactions
    }
    
}
