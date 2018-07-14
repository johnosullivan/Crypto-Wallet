//
//  Chain.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/18/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import Geth
import UIKit

class NewHeadHandler: NSObject, GethNewHeadHandlerProtocol {
    
    let errorHandler: ((String) -> Void)?
    let newHeadHandler: ((GethHeader) -> Void)?
    
    init(errorHandler: ((String) -> Void)?, newHeadHandler: ((GethHeader) -> Void)?) {
        self.errorHandler = errorHandler
        self.newHeadHandler = newHeadHandler
        super.init()
    }
    
    func onError(_ failure: String!) {
        errorHandler?(failure)
    }
    
    func onNewHead(_ header: GethHeader!) {
        newHeadHandler?(header)
    }
    
}


enum SyncMode: Int {
    case standard
    case secure
    
   
}

protocol NodeProtocol {
    var chain: Chain { get }
    func start() throws
    func stop() throws
    func ethereumClient() throws -> GethEthereumClient
}

class Node: NodeProtocol {
    
    let chain: Chain
    private let gethNode: GethNode
    private var _ethereumClient: GethEthereumClient?
    
    init(chain: Chain) throws {
        self.chain = chain
        
        var error: NSError?
        let config = GethNewNodeConfig()!
        config.setEthereumGenesis(chain.genesis)
        config.setEthereumNetworkID(chain.ChainID)
        config.setMaxPeers(25)
        
        if let bootNode = chain.enode {
            var error: NSError?
            let bootNodes = GethNewEnodesEmpty()!
            bootNodes.append(GethNewEnode(bootNode, &error))
        }
        
        if let stats = chain.netStats {
            config.setEthereumNetStats(stats)
        }
        
        let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        gethNode = GethNewNode(datadir + chain.path, config, &error)
        
        guard error == nil else {
            throw error! as Error
        }
    }
    
    func start() throws {
        try gethNode.start()
    }
    
    func stop() throws {
        try gethNode.stop()
    }
    
    func ethereumClient() throws -> GethEthereumClient {
        if let client = _ethereumClient { return client }
        _ethereumClient = try gethNode.getEthereumClient()
        return _ethereumClient!
    }
}


enum Chain: String {
    
    case mainnet
    case ropsten
    case rinkeby
    
    static var `default`: Chain {
        return .mainnet
    }
    
    var ChainID: Int64 {
        switch self {
        case .mainnet:
            return 1
        case .ropsten:
            return 3
        case .rinkeby:
            return 4
        }
    }
    
    var netStats: String? {
        switch self {
            default:
                return nil
        }
    }
    
    var enode: String? {
        switch self {
        case .mainnet:
            return nil
        case .ropsten:
            return Constants.Ethereum.ropstenEnodeRawUrl
        case .rinkeby:
            return Constants.Ethereum.rinkebyEnodeRawUrl
        }
    }
    
    var genesis: String {
        switch self {
            case .mainnet:
                return GethMainnetGenesis()
            case .ropsten:
                return GethTestnetGenesis()
            case .rinkeby:
                return GethRinkebyGenesis()
        }
    }
    
    var description: String {
        return "\(self)"
    }
    
    var localizedDescription: String {
        switch self {
            case .mainnet:
                return "Mainnet"
            case .ropsten:
                return "Ropsten Testnet"
            case .rinkeby:
                return "Rinkeby Testnet"
        }
    }
    
    var path: String {
        return "/.\(description)"
    }
    
    var etherscanApiUrl: String {
        switch self {
            case .mainnet:
                return "api.etherscan.io"
            case .ropsten:
                return "ropsten.etherscan.io"
            case .rinkeby:
                return "rinkeby.etherscan.io"
        }
    }
    
    var clientUrl: String {
        switch self {
            case .mainnet:
                return "https://mainnet.infura.io"
            case .ropsten:
                return "https://ropsten.infura.io"
            case .rinkeby:
                return "https://rinkeby.infura.io"
        }
    }
    
    var etherscanUrl: String {
        switch self {
            case .mainnet:
                return "https://etherscan.io"
            case .ropsten:
                return "https://ropsten.etherscan.io"
            case .rinkeby:
                return "https://rinkeby.etherscan.io"
        }
    }
    
    var isMainnet: Bool {
        return self == .mainnet
    }
    
    static func all() -> [Chain] {
        return [.mainnet, .ropsten, .rinkeby]
    }
    
}
