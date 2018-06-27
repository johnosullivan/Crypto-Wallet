//
//  APIRate.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/20/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RealmSwift

protocol RealmMappable {
    
    associatedtype RealmType: Object
    
    init()
    func mapToRealmObject() -> RealmType
    static func mapFromRealmObject(_ object: RealmType) -> Self
    
}

class RealmRate: Object {
    
    @objc dynamic var value: Double = 0.0
    @objc dynamic var from: String = ""
    @objc dynamic var to: String = ""
    @objc dynamic var fromTo: String = ""
    
    
    override static func primaryKey() -> String? {
        return "fromTo"
    }
    
}


struct Rate {
    
    var value: Double!
    var from: String!
    var to: String!
    
    static func mapFromRealmObject(_ object: RealmRate) -> Rate {
        var rate = Rate()
        rate.value = object.value
        rate.from = object.from
        rate.to = object.to
        return rate
    }
    
    func mapToRealmObject() -> RealmRate {
        let realmObject = RealmRate()
        realmObject.value = value
        realmObject.from = from
        realmObject.to = to
        realmObject.fromTo = "\(from)-\(to)"
        return realmObject
    }
    
}

// MARK: - Mapping

extension Rate {
    
    init(from: String, to: String, value: Double) {
        self.from = from
        self.to = to
        self.value = value
    }
    
}

extension API {
    
    enum Rate {
        case rate(currencies: [String])
    }
    
}

struct Coin {
    
    var balance: Currency!
    var rates = [Rate]()
    var lastUpdateTime = Date()
    
}

class RealmCoin: Object {
    
    @objc dynamic var balance: String = "0"
    @objc dynamic var name: String = ""
    @objc dynamic var iso: String = ""
    @objc dynamic var lastUpdateTime: Date = .distantPast
    var rates = List<RealmRate>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
}

extension Coin: RealmMappable {
    
    static func mapFromRealmObject(_ object: RealmCoin) -> Coin {
        var coin = Coin()
        coin.balance = Ether(object.balance)
        coin.rates = object.rates.map { Rate.mapFromRealmObject($0) }
        coin.lastUpdateTime = object.lastUpdateTime
        return coin
    }
    
    func mapToRealmObject() -> RealmCoin {
        let realmObject = RealmCoin()
        realmObject.balance = balance.raw.string
        realmObject.name = balance.name
        realmObject.iso = balance.iso
        realmObject.rates.append(objectsIn: rates.map { $0.mapToRealmObject() })
        realmObject.lastUpdateTime = lastUpdateTime
        return realmObject
    }
    
}

extension API.Rate: APIMethodProtocol {
    
    var path: String {
        return "https://min-api.cryptocompare.com/data/pricemulti?"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var params: Params? {
        switch self {
        case .rate(let currencies):
            return [
                "fsyms": currencies.joined(separator: ","),
                "tsyms": Constants.Wallet.SupportedCurrencies.joined(separator: ",")
            ]
        }
    }
    
}

protocol RatesNetworkServiceProtocol {
    func getRate(currencies: [String], completion: @escaping (Result<[Rate]>) -> Void)
}

class RatesNetworkService: NetworkLoadable, RatesNetworkServiceProtocol {
    
    func getRate(currencies: [String], completion: @escaping (Result<[Rate]>) -> Void) {
        loadObjectJSON(request: API.Rate.rate(currencies: currencies)) { result in
            switch result {
            case .success(let json):
                guard let object = json as? [String: Any] else {
                    completion(.failure(NetworkError.parseError))
                    return
                }
                
                var rates = [Rate]()
                for key in object.keys {
                    if let rateInfo = object[key] as? [String: Double] {
                        let newRates = rateInfo.map { Rate(from: key, to: $0.key, value: $0.value) }
                        rates.append(contentsOf: newRates)
                    }
                }
                
                completion(.success(rates))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
