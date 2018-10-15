//
//  GasService.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/19/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import Geth
import Alamofire


protocol GasServiceProtocol {
    
    /// EstimateGas tries to estimate the gas needed to execute a specific transaction based on
    /// the current pending state of the backend blockchain. There is no guarantee that this is
    /// the true gas limit requirement as other transactions may be added or removed by miners,
    /// but it should provide a basis for setting a reasonable default.
    ///
    /// - Returns: Int64 GasLimit
    func getSuggestedGasLimit(result: @escaping (Result<Int64>) -> Void)
    
    /// SuggestGasPrice retrieves the currently suggested gas price to allow a timely
    /// execution of a transaction.
    ///
    /// - Returns: Int64 GasPrice
    func getSuggestedGasPrice(result: @escaping (Result<Int64>) -> Void)
    
}


class GasService: GasServiceProtocol {
    
    private let client: GethEthereumClient
    private let context: GethContext
    
    init(core: Ethereum) {
        self.client = core.client
        self.context = core.context        
    }
    
    func getSuggestedGasLimit(result: @escaping (Result<Int64>) -> Void) {
        Ethereum.syncQueue.async {
            do {
                let msg = GethNewCallMsg()
                var gas:Int64 = 0
                try self.client.estimateGas(self.context, msg: msg, gas: &gas)
                DispatchQueue.main.async {
                    result(.success(gas))
                }
            } catch {
                DispatchQueue.main.async {
                    result(.failure(error))
                }
            }
        }
    }
    
    func getSuggestedGasPrice(result: @escaping (Result<Int64>) -> Void) {
        Ethereum.syncQueue.async {
            do {
                let gasPrice = try self.client.suggestGasPrice(self.context)
                DispatchQueue.main.async {
                    result(.success(gasPrice.getInt64()))
                }
            } catch {
                DispatchQueue.main.async {
                    result(.failure(error))
                }
            }
        }
    }
    
}
