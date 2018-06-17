//
//  AppDelegate.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/11/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import Geth

protocol CustomError: Error {
    typealias ErrorInfo = (title: String?, message: String?, showing: Bool)
    var description: ErrorInfo? { get }
}

extension CustomError {
    var criticalError: ErrorInfo {
        return (title: "Critical error", message: "Something went wront. Please contact with developers", showing: true)
    }
}

enum NetworkError: CustomError {
    case parseError
    
    var description: CustomError.ErrorInfo? {
        return nil
    }
}

struct Transaction {
    var txHash: String!
    var to: String!
    var from: String!
    var amount: Currency!
    var timestamp: Date!
    var isIncoming: Bool!
    var isPending: Bool!
    var isError: Bool!
    var isTokenTransfer: Bool!
    
    static func mapFromGethTransaction(_ object: GethTransaction, time: TimeInterval) -> Transaction {
        var transaction = Transaction()
        transaction.txHash = object.getHash().getHex()
        transaction.to = object.getTo().getHex()
        transaction.from = ""
        transaction.amount = Ether(weiString: object.getValue().string()!)
        transaction.timestamp = Date(timeIntervalSince1970: time)
        transaction.isPending = false
        transaction.isError = false
        transaction.isTokenTransfer = false
        return transaction
    }
    
}

extension Transaction: ImmutableMappable {
    
    init(map: Map) throws {
        txHash = try map.value("hash")
        to = try map.value("to")
        from = try map.value("from")
        let amountString: String = try map.value("value")
        amount = Ether(weiString: amountString)
        timestamp = try map.value("timeStamp", using: DateTransform())
        let isErrorString: String = try map.value("isError")
        isError = Bool(isErrorString)
        isPending = false
        isTokenTransfer = false
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NetworkLoadable {

    var window: UIWindow?

    func getBalance(address: String, result: @escaping (Result<String>) -> Void) {
        loadObjectJSON(request: API.Etherscan.balance(address: address)) { resultHandler in
            
            switch resultHandler {
            case .success(let object):
                
                guard let json = object as? [String: Any], let balance = json["result"] as? String else {
                    result(Result.failure(NetworkError.parseError))
                    return
                }
                
                result(Result.success(balance))
                
            case .failure(let error):
                result(Result.failure(error))
            }
            
        }
    }
    
    func getTransactions(address: String, result: @escaping (Result<[Transaction]>) -> Void) {
        loadArray(request: API.Etherscan.transactions(address: address), keyPath: "result", completion: result)
    }
    
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        getBalance(address: "0x51e003aeb3feb22093528f0c6fc046c498e2d8d3") { result in
            switch result {
                case .success(let balance):
                    let ether = Ether(weiString: balance)
                    print("FullName: ", ether.fullNameWithSymbol)
                    print("Value: ", ether.value)
                case .failure(let error):
                    print(error)
            }
        }
        
        getTransactions(address: "0x51e003aeb3feb22093528f0c6fc046c498e2d8d3") { result in
            switch result {
            case .success(let transactions):
                    print("Transactions: ", transactions.count)
                case .failure(let error):
                    print(error)
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Crypto_Wallet")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

