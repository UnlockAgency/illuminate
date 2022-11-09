//
//  UserDefault.swift
//  Illuminate
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<Value: Codable> {
    public let key: String
    private var defaultValue: Value!

    public init(wrappedValue: Value, key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }

    public init(key: String) {
        self.key = key
    }

    public var wrappedValue: Value {
        get {
            return get()
        }
        set {
            optionalSet(newValue)
        }
    }

    private func get() -> Value {
        guard let defaultsValue = UserDefaults.standard.object(forKey: key) else {
            optionalSet(defaultValue)
            if defaultValue == nil {
                guard let value = (Optional<Value>.none as Any) as? Value else {
                    fatalError("Something went wrong while unwrapping to \(Value.self)")
                }
                return value
            }
            return defaultValue
        }

        if let value = defaultsValue as? Value {
            return value

        } else if let data = defaultsValue as? Data {
            let decoder = JSONDecoder()

            do {
                return try decoder.decode(Value.self, from: data)
            } catch let error {
                fatalError("\(error)")
            }
        } else {
            fatalError("Value is not of a Codable or PropertyListValue")
        }
    }

    private func optionalSet(_ value: Value?) {
        switch value {
        case .none:
            clear()
        case .some(let value):
            if let propertyListValue = value as? PropertyListValue {
                UserDefaults.standard.set(propertyListValue, forKey: key)
                return
            }

            let encoder = JSONEncoder()
            let data = try? encoder.encode(value)
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    public func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension NSData: PropertyListValue {}

extension String: PropertyListValue {}
extension NSString: PropertyListValue {}

extension Date: PropertyListValue {}
extension NSDate: PropertyListValue {}

extension NSNumber: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Int8: PropertyListValue {}
extension Int16: PropertyListValue {}
extension Int32: PropertyListValue {}
extension Int64: PropertyListValue {}
extension UInt: PropertyListValue {}
extension UInt8: PropertyListValue {}
extension UInt16: PropertyListValue {}
extension UInt32: PropertyListValue {}
extension UInt64: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}

extension Array: PropertyListValue where Element: PropertyListValue { }
extension Dictionary: PropertyListValue where Key: PropertyListValue, Value: PropertyListValue { }
