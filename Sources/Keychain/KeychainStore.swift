//
//  KeychainStore.swift
//
//  Created by Thomas Roovers on 25/08/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import IlluminateInjection

@propertyWrapper
public struct KeychainStore<Value: Codable> {
    public let key: String
    public let service: String
    
    private var keychainsService: KeychainsService {
        return InjectSettings.resolver.resolve(KeychainsService.self)!
    }
    
    public init(wrappedValue: Value? = nil, service: String, key: String) {
        self.service = service
        self.key = key
        self.wrappedValue = get() ?? wrappedValue
    }
    
    public var wrappedValue: Value? {
        didSet {
            write(wrappedValue)
        }
    }
    
    private func get() -> Value? {
        let keychain = keychainsService.instance(service: service)
        guard let data = try? keychain.getData(key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(Value.self, from: data)
    }

    private func write(_ value: Value?) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(value) else {
            return
        }
        try? keychainsService.instance(service: service).set(data, key: key)
    }

    public func clear() {
        try? keychainsService.instance(service: service).remove(key)
    }
}
