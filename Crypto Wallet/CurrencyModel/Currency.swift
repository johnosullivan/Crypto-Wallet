//
//  Currency.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/13/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit

protocol Currency {
    var raw: Decimal { get }
    var value: Double { get }
    var name: String { get }
    var iso: String { get }
    var symbol: String { get }
}

extension Currency {
   
    var fullName: String { return "\(name) (\(iso))" }
    
    var fullNameWithSymbol: String { return "\(symbol)\t\(fullName)" }
    
    var amount: String {
        let valueString = NSDecimalNumber(string: "\(value)").stringValue
        return "\(valueString) \(symbol)"
    }
    
    func amount(in iso: String, rate: Double) -> String {
        let total = value * rate
        return total.amount(for: iso)
    }
    
}
