//
//  EthereumTools.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/11/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func isValidAddress() -> Bool {
        return count == 42 && self[0..<2] == "0x"
        
    }
    
    func retriveAddress() -> String {
        let parts = components(separatedBy: ":")
        return parts.last ?? self
    }
    
}


extension Decimal {
    
    func fromWei() -> Decimal { return self / 1e18 }
    
    func toWei() -> Decimal {   return self * 1e18 }
    
    func localToEther(rate: Double) -> Decimal { return self / Decimal(rate) }
    
    func etherToLocal(rate: Double) -> Decimal { return self * Decimal(rate) }
    
    func weiToGwei() -> Decimal { return self / 1000000000 }
    
    func toHex() -> String { return representationOf(base: 16) }
    
    func amount(for iso: String) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = .current
        currencyFormatter.currencyCode = iso
        return currencyFormatter.string(from: self as NSDecimalNumber)!
    }
    
    init(hexString: String) { self.init(hexString, base: 16) }
}

extension Decimal {
    
    private func rounded(mode: NSDecimalNumber.RoundingMode) -> Decimal {
        var this = self
        var result = Decimal()
        NSDecimalRound(&result, &this, 0, mode)
        
        return result
    }
    
    private func integerDivisionBy(_ operand: Decimal) -> Decimal{
        let result = (self / operand)
        return result.rounded(mode: result < 0 ? .up : .down)
    }
    
    private func truncatingRemainder(dividingBy operand: Decimal) -> Decimal {
        return self - self.integerDivisionBy(operand) * operand
    }
    
    private init(_ string: String, base: Int) {
        var decimal: Decimal = 0
        
        let digits = string.characters
            .map { String($0) }
            .map { Int($0, radix: base)! }
        
        for digit in digits {
            decimal *= Decimal(base)
            decimal += Decimal(digit)
        }
        
        self.init(string: decimal.description)!
    }
    
    private func representationOf(base: Decimal) -> String {
        var buffer: [Int] = []
        var n = self
        
        while n > 0 {
            buffer.append((n.truncatingRemainder(dividingBy: base) as NSDecimalNumber).intValue)
            n = n.integerDivisionBy(base)
        }
        
        return buffer
            .reversed()
            .map { String($0, radix: (base as NSDecimalNumber).intValue ) }
            .joined()
    }
}
