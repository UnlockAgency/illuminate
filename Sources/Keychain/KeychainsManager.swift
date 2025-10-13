//
//  KeychainsManager.swift
//
//  Created by Thomas Roovers on 25/08/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain: KeychainService {
    public func set(_ data: Data, key: String) throws {
        try set(data, key: key, ignoringAttributeSynchronizable: true)
    }
    
    public func getData(_ key: String) throws -> Data? {
        return try getData(key, ignoringAttributeSynchronizable: true)
    }
    
    public func remove(_ key: String) throws {
        try remove(key, ignoringAttributeSynchronizable: true)
    }
}

public class KeychainsManager: KeychainsService {
    public init() {
        
    }
    
    public func instance(service: String) -> KeychainService {
        return Keychain(service: service)
    }
}
