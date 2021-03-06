//
//  Ether.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/13/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit

struct Ether {
    
    var raw: Decimal
    var value: Double
    
    init(_ value: Decimal) {
        self.raw = value
        self.value = value.double
    }
    
    init(weiValue: Decimal) {
        self.raw = weiValue / 1e18
        self.value = weiValue.double / 1e18
    }
    
    init(_ double: Double) {
        self.raw = Decimal(double)
        self.value = double
    }
    
    init(_ string: String) {
        let number = Decimal(string)
        self.init(number)
    }
    
    init(weiString: String) {
        let number = Decimal(weiString)
        self.init(weiValue: number)
    }
    
    mutating func update(weiString: String) {
        let number = Decimal(weiString)
        self.raw = number / 1e18
        self.value = number.double / 1e18
    }
    
}

extension Ether: Currency {
    
    var name: String { return "Ethereum" }
    
    var iso: String { return "ETH" }
    
    var symbol: String { return "Ξ" }
    
    var description: String { return "" }
    
}
