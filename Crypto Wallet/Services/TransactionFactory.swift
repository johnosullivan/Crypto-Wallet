//
//  TransactionFactory.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/19/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import Geth
import Alamofire

enum TransferType {
    case `default`
    case token
}


struct TransactionInfo {
    let amount: Decimal
    let address: String
    let contractAddress: String?
    let gasLimit: Decimal
    let gasPrice: Decimal
}


protocol TransactionServiceProtocol {
    /// Send transaction
    ///
    /// - Parameters:
    ///   - info: TransactionInfo object containing: amount, address, gas limit
    ///   - passphrase: Password to unlock wallet
    func sendTransaction(with info: TransactionInfo, passphrase: String, result: @escaping (Result<GethTransaction>) -> Void)
}

class TransactionService: TransactionServiceProtocol {
    
    private let context: GethContext
    private let client: GethEthereumClient
    private let keystore: KeystoreService
    private let chain: Chain
    private let factory: TransactionFactoryProtocol
    private let transferType: TransferType
    
    init(core: Ethereum, keystore: KeystoreService, transferType: TransferType) {
        self.context = core.context
        self.client = core.client
        self.chain = core.chain
        self.keystore = keystore
        self.transferType = transferType
        
        let factory = TransactionFactory(keystore: keystore, core: core)
        self.factory = factory
    }
    
    func sendTransaction(with info: TransactionInfo, passphrase: String, result: @escaping (Result<GethTransaction>) -> Void) {
        Ethereum.syncQueue.async {
            do {
                let account = try self.keystore.getAccount(at: 0)
                let transaction = try self.factory.buildTransaction(with: info, type: self.transferType)
                let signedTransaction = try self.keystore.signTransaction(transaction, account: account, passphrase: passphrase, chainId: self.chain.ChainID)
                try self.sendTransaction(signedTransaction)
                DispatchQueue.main.async {
                    result(.success(signedTransaction))
                }
            } catch {
                DispatchQueue.main.async {
                    result(.failure(error))
                }
            }
        }
    }
    
    private func sendTransaction(_ signedTransaction: GethTransaction) throws {
        try client.sendTransaction(context, tx: signedTransaction)
    }
    
}

protocol TransactionFactoryProtocol {
    func buildTransaction(with info: TransactionInfo, type: TransferType) throws -> GethTransaction
}


class TransactionFactory: TransactionFactoryProtocol {
    
    let keystore: KeystoreService
    let client: GethEthereumClient
    let context: GethContext
    
    init(keystore: KeystoreService, core: Ethereum) {
        self.keystore = keystore
        self.client = core.client
        self.context = core.context
    }
    
    func buildTransaction(with info: TransactionInfo, type: TransferType) throws -> GethTransaction {
        switch type {
        case .default:
            return try buildTransaction(with: info)
        case .token:
            return try buildTransaction(with: info)
        }
    }
    
}


// MARK: Privates

extension TransactionFactory {
    
    private func buildTransaction(with info: TransactionInfo) throws -> GethTransaction {
        var error: NSError?
        let receiverAddress = info.contractAddress ?? info.address
        let gethAddress = GethNewAddressFromHex(receiverAddress, &error)
        var noncePointer: Int64 = 0
        let account = try keystore.getAccount(at: 0)
        try client.getNonceAt(context, account: account.getAddress(), number: -1, nonce: &noncePointer)
        
        let intAmount = GethNewBigInt(0)
        intAmount?.setString(info.amount.toHex(), base: 16)
        
        let gethGasLimit = GethNewBigInt(0)
        gethGasLimit?.setString(info.gasLimit.toHex(), base: 16)
        let gethGasPrice = GethNewBigInt(0)
        gethGasPrice?.setString(info.gasPrice.toHex(), base: 16)
        
        return GethNewTransaction(noncePointer, gethAddress, intAmount, (gethGasLimit?.getInt64())!, gethGasPrice, nil)
    }
    
}

enum TransactionFactoryError: Error {
    case badSignature
}
