//
//  Constants.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/14/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit

struct Constants {
    
    struct Ethereum {
        static let rinkebyEnodeRawUrl = "enode://a24ac7c5484ef4ed0c5eb2d36620ba4e4aa13b8c84684e1b4aab0cebea2ae45cb4d375b77eab56516d34bfbd3c1a833fc51296ff084b770b94fb9028c4d25ccf@52.169.42.101:30303?discport=30304"
        static let ropstenEnodeRawUrl = "enode://a24ac7c5484ef4ed0c5eb2d36620ba4e4aa13b8c84684e1b4aab0cebea2ae45cb4d375b77eab56516d34bfbd3c1a833fc51296ff084b770b94fb9028c4d25ccf@52.169.42.101:30303?discport=30304"
    }
    
    struct Etherscan {
        static let apiKey = "DI5D2RRNSJI5H6BNI3Z6JZB1RD4F2TKX9X"
    }
    
    struct Wallet {
        static let defaultCurrency = "USD"
        static let supportedCurrencies = ["BTC","ETH","USD","EUR","CNY","GBP"]
    }
    
    struct Common {
        
    }
    
    struct Send {
        static let defaultGasLimit: Decimal = 21000
        static let defaultGasLimitToken: Decimal = 53000
        static let defaultGasPrice: Decimal = 2000000000
    }
    
}
