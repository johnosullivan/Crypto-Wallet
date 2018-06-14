//
//  API.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/13/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Foundation
import Alamofire


enum API {}

protocol APIMethodProtocol: URLRequestConvertible {
    var method: Alamofire.HTTPMethod { get }
    var path: String { get }
    var params: Params? { get }
    var headers: [String: String] { get }
}

extension APIMethodProtocol {
    
    typealias Params = [String: Any?]
    
    var baseUrl: String {
        return ""
    }
    
    var requestTimeout: TimeInterval {
        return 20
    }
    
    var path: String {
        return ""
    }
    
    var params: Params? {
        return nil
    }
    
    var headers: [String: String] {
        return [String: String]()
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try (baseUrl + path).asURL()
        
        var urlRequest = Alamofire.URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.timeoutInterval = requestTimeout
        urlRequest.httpMethod = method.rawValue
        
        for header in headers {
            urlRequest.setValue(header.1, forHTTPHeaderField: header.0)
        }
        
        switch method {
            case .get:
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: params?.safe())
            case .post:
                return try Alamofire.JSONEncoding.default.encode(urlRequest, with: params?.safe())
            default:
                return urlRequest
        }
    }
    
}

extension Dictionary where Key == String, Value == Any? {
    
    func safe() -> [String: Any] {
        var dict = [String: Any]()
        for (key, value) in self {
            if let value = value {
                dict[key] = value
            }
        }
        return dict
    }
    
}
