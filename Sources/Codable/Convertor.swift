//
//  Convertor.swift
//  
//
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

public enum ConvertorError: Swift.Error, Sendable {
    case valueTypeMismatch
    case shouldAlwaysDecode
}

public protocol ConvertorValueProvider: Sendable {
    associatedtype ReturnType = Equatable & Codable & Sendable
    static var defaultValue: ReturnType { get }
    associatedtype ValueType = Codable & Sendable
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
public struct CodableConvertor<Provider: ConvertorValueProvider>: Codable, CustomDebugStringConvertible, Sendable where Provider.ReturnType: Codable & Sendable, Provider.ValueType: Codable & Sendable {
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
            if Provider.shouldAlwaysDecode() {
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
