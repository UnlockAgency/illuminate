//
//  Convertor.swift
//  
//
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

public enum ConvertorError: Swift.Error {
    case valueTypeMismatch
    case shouldAlwaysDecode
}

public protocol ConvertorValueProvider {
    associatedtype ReturnType = Equatable & Codable
    static var defaultValue: ReturnType { get }
    associatedtype ValueType = Codable
    static func decode(from value: ValueType) -> ReturnType
    static func encode(from value: ReturnType) -> ValueType
    static func shouldAlwaysDecode() -> Bool
}

public extension ConvertorValueProvider {
    static func shouldAlwaysDecode() -> Bool {
        return false
    }
}

@propertyWrapper
public struct CodableConvertor<Provider: ConvertorValueProvider>: Codable, CustomDebugStringConvertible where Provider.ReturnType: Codable, Provider.ValueType: Codable {
    public var wrappedValue: Provider.ReturnType

    public init() {
        wrappedValue = Provider.defaultValue
    }

    public init(wrappedValue: Provider.ReturnType) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            wrappedValue = Provider.defaultValue
            return
        }
        
        do {
            if Provider.ReturnType.self != Provider.ValueType.self {
                throw ConvertorError.valueTypeMismatch
                
            } else if Provider.shouldAlwaysDecode() {
                throw ConvertorError.shouldAlwaysDecode
            }
            wrappedValue = try container.decode(Provider.ReturnType.self)
        } catch {
            if let value = try? container.decode(Provider.ValueType.self) {
                wrappedValue = Provider.decode(from: value)
            } else {
                wrappedValue = Provider.defaultValue
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        do {
            try wrappedValue.encode(to: encoder)
        } catch {
            try? Provider.encode(from: wrappedValue).encode(to: encoder)
        }
    }
    
    public var debugDescription: String {
        return String(describing: wrappedValue)
    }
}
