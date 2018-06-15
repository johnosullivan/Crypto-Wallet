//
//  APIEth.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/13/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation

import Alamofire

extension API {
    
    enum Etherscan {
        case transactions(address: String)
        case balance(address: String)
    }
    
}

extension API.Etherscan: APIMethodProtocol {
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "https://ropsten.etherscan.io/api?"
    }
    
    var params: Params? {
        switch self {
        case .transactions(let address):
            return [
                "module": "account",
                "action": "txlist",
                "address": address,
                "startblock": 0,
                "endblock": 99999999,
                "sort": "asc",
                "apiKey": Constants.Etherscan.apiKey
            ]
        case .balance(let address):
            return [
                "module": "account",
                "action": "balance",
                "address": address,
                "tag": "latest",
                "apiKey": Constants.Etherscan.apiKey
            ]
        }
    }
    
}
