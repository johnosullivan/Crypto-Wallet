//
//  BuildHelper.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/12/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit

extension Bundle {
    
    var versionAndBuild: String {
        let version = infoDictionary!["CFBundleShortVersionString"] as! String
        let build = infoDictionary!["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
    
}
