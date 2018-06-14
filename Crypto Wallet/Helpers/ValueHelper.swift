//
//  DecimalHelper.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/13/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit

extension Decimal {
    
    init(_ string: String) {
        if let _ = Decimal(string: string) {
            self.init(string: string)!
            return
        }
        self.init(string: "0")!
    }
    
    var string: String {
        return String(describing: self)
    }
    
    var double: Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
    
    func abbrevation() -> String {
        let numFormatter = NumberFormatter()
        
        typealias Abbrevation = (threshold: Decimal, divisor: Decimal, suffix: String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (100_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 1_000_000_000.0, "B")]
        
        let abbreviation: Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if self < tmpAbbreviation.threshold {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()
        
        let value = self / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        
        return numFormatter.string(for: value) ?? self.string
    }
    
}

extension Double {
    
    func amount(for iso: String) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = .current
        currencyFormatter.currencyCode = iso
        return currencyFormatter.string(from: Decimal(floatLiteral: self) as NSDecimalNumber)!
    }
    
}
