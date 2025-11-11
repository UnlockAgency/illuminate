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
    
    public func set<T: Codable>(_ value: T, key: String) throws {
        let data = try JSONEncoder().encode(value)
        try set(data, key: key)
    }
    
    public func getData<T: Codable>(_ key: String, ofType type: T.Type) throws -> T? {
        guard let data = try getData(key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

public class KeychainsManager: KeychainsService {
    public init() {
        
    }
    
    public func instance(service: String) -> KeychainService {
        return Keychain(service: service)
    }
}
