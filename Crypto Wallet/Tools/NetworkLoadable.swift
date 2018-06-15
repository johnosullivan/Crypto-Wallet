//
//  NetworkLoadable.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/13/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import Alamofire
import ObjectMapper
import AlamofireObjectMapper

protocol NetworkLoadable {
    typealias ResultObjectBlock<T> = (Result<T>) -> Void
    typealias ResultJSONBlock = (Result<Any>) -> Void
    typealias ResultArrayBlock<T> = (Result<[T]>) -> Void
    
    func loadObject<PlainType: ImmutableMappable>(request: URLRequestConvertible, keyPath: String?, completion: @escaping ResultObjectBlock<PlainType>)
    func loadObjectJSON(request: URLRequestConvertible, completion: @escaping ResultJSONBlock)
    func loadArrayJSON(request: URLRequestConvertible, completion: @escaping ResultJSONBlock)
    func loadArray<PlainType: ImmutableMappable>(request: URLRequestConvertible, keyPath: String?, completion: @escaping ResultArrayBlock<PlainType>)
}

extension NetworkLoadable {
    
    // MARK: - Response Object
    
    func loadObject<PlainType: ImmutableMappable>(request: URLRequestConvertible, keyPath: String? = nil, completion: @escaping ResultObjectBlock<PlainType>) {
        let operation = AnyOperation(request: request,
                                     responseSerializer: DataRequest.ObjectMapperImmutableSerializer(keyPath, context: nil),
                                     completion: completion)
        operation.execute()
    }
    
    // MARK: - Response JSON
    
    func loadObjectJSON(request: URLRequestConvertible, completion: @escaping ResultJSONBlock) {
        let operation = AnyOperation(request: request,
                                     responseSerializer: DataRequest.jsonResponseSerializer(options: .allowFragments),
                                     completion: completion)
        operation.execute()
    }
    
    func loadArrayJSON(request: URLRequestConvertible, completion: @escaping ResultJSONBlock) {
        let operation = AnyOperation(request: request,
                                     responseSerializer: DataRequest.jsonResponseSerializer(options: .allowFragments),
                                     completion: completion)
        operation.execute()
    }
    
    // MARK: - Response Array
    
    func loadArray<PlainType: ImmutableMappable>(request: URLRequestConvertible, keyPath: String? = nil, completion: @escaping ResultArrayBlock<PlainType>) {
        let operation = AnyOperation(request: request,
                                     responseSerializer: DataRequest.ObjectMapperImmutableArraySerializer(keyPath, context: nil),
                                     completion: completion)
        operation.execute()
    }
}

private protocol NetworkOperationProtocol {
    associatedtype ResponseSerializer: DataResponseSerializerProtocol
    typealias ResponseObject = ResponseSerializer.SerializedObject
    
    var request: URLRequestConvertible { get }
    var responseSerializer: ResponseSerializer { get }
    var completion: ((Result<ResponseObject>) -> Void)? { get }
}

private struct AnyOperation<ResponseSerializer: DataResponseSerializerProtocol>: NetworkOperationProtocol {
    
    var request: URLRequestConvertible
    var responseSerializer: ResponseSerializer
    var completion: ((Result<ResponseSerializer.SerializedObject>) -> Void)?
    
    func execute() {
        Alamofire.request(request).response(queue: DispatchQueue.main, responseSerializer: responseSerializer) { response in
            self.completion?(response.result)
        }
    }
}
