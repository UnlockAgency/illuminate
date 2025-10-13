//
//  DefaultCodable.swift
//
//
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol DefaultCodableStrategy: Sendable {
    associatedtype RawValue: Codable & Sendable
    static var defaultValue: RawValue { get }
}

public struct DefaultFalseStrategy: DefaultCodableStrategy {
    public static var defaultValue: Bool {
        return false
    }
}

public struct DefaultTrueStrategy: DefaultCodableStrategy {
    public static var defaultValue: Bool {
        return true
    }
}

public struct DefaultZeroStrategy<T: Numeric & Codable & Sendable>: DefaultCodableStrategy {
    public static var defaultValue: T {
        // swiftlint:disable force_cast
        if T.self == Int.self {
            return Int(0) as! T
            
        } else if T.self == UInt.self {
            return UInt(0) as! T
            
        } else if T.self == Double.self {
            return Double(0) as! T
            
        } else if T.self == Float.self {
            return Float(0) as! T
            
        } else if T.self == CGFloat.self {
            return CGFloat(0) as! T
        }
        return 0 as! T // This will probably fail
        
        // swiftlint:enabled force_cast
    }
}

public struct DefaultEmptyStrategy<T>: DefaultCodableStrategy where T: Codable & RangeReplaceableCollection & Sendable {
    public static var defaultValue: T {
        return T()
    }
}

public struct DefaultEmptyDictionaryStrategy<T: Codable & Hashable & Sendable, U: Codable & Sendable>: DefaultCodableStrategy {
    public static var defaultValue: [T: U] {
        return [:]
    }
}

public struct DefaultNilStrategy<T: Codable & Sendable>: DefaultCodableStrategy {
    public static var defaultValue: T? {
        nil
    }
}

public protocol DefaultValueProvider {
    associatedtype Value = Equatable & Codable & Sendable
    static var defaultValue: Value { get }
}

/// If decoding returns `nil` or throws an error: Fallback to an empty array
public typealias DefaultEmptyDictionary<T, U> = DefaultCodable<DefaultEmptyDictionaryStrategy<T, U>> where T: Codable & Hashable & Sendable, U: Codable & Sendable

/// If decoding returns `nil` or throws an error: Fallback to `nil`
public typealias DefaultNil<T> = DefaultCodable<DefaultNilStrategy<T>> where T: Codable & Sendable

/// If decoding returns `nil` or throws an error: Fallback to `false`
public typealias DefaultFalse = DefaultCodable<DefaultFalseStrategy>

/// If decoding returns `nil` or throws an error: Fallback to and empty string (`""`) or array (`[]`)
public typealias DefaultEmpty<T> = DefaultCodable<DefaultEmptyStrategy<T>> where T: Codable & RangeReplaceableCollection & Sendable

/// If decoding returns `nil` or throws an error: Fallback to `true`
public typealias DefaultTrue = DefaultCodable<DefaultTrueStrategy>

/// If decoding returns `nil` or throws an error: Fallback to `0`
public typealias DefaultZero<T> = DefaultCodable<DefaultZeroStrategy<T>> where T: Numeric & Codable & Sendable

/// If decoding returns `nil` or throws an error: Fallback to the first enum element
public enum FirstEnumCase<A>: DefaultValueProvider where A: Codable & Equatable & CaseIterable & Sendable {
    public static var defaultValue: A { A.allCases.first! }
}

/// If decoding returns `nil` or throws an error: Fallback to the last enum element
public enum LastEnumCase<A>: DefaultValueProvider where A: Codable & Equatable & CaseIterable & Sendable {
    public static var defaultValue: A { A.allCases[(A.allCases.count - 1) as! A.AllCases.Index] } // swiftlint:disable:this force_cast
}

@propertyWrapper
public struct DefaultCodable<Strategy: DefaultCodableStrategy>: Codable, CustomDebugStringConvertible, Sendable {
    public var wrappedValue: Strategy.RawValue

    public init(wrappedValue: Strategy.RawValue) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode(Strategy.RawValue.self)
        } catch {
            print("IlluminateCodable [Warning] Error decoding \(Strategy.RawValue.self): \(error), falling back to \(Strategy.defaultValue)")
            self.wrappedValue = Strategy.defaultValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
    
    public var debugDescription: String {
        return String(describing: wrappedValue)
    }
}

public extension KeyedDecodingContainer {
    func decode<Strategy>(_: DefaultCodable<Strategy>.Type, forKey key: Key) throws -> DefaultCodable<Strategy> {
        if let value = try decodeIfPresent(DefaultCodable<Strategy>.self, forKey: key) {
            return value
        } else {
            return DefaultCodable(wrappedValue: Strategy.defaultValue)
        }
    }
}

extension DefaultCodable: Equatable where Strategy.RawValue: Equatable { }
extension DefaultCodable: Hashable where Strategy.RawValue: Hashable { }

public protocol Numeric { }
extension Int: Numeric { }
extension UInt: Numeric { }
extension Double: Numeric { }
extension Float: Numeric { }
extension CGFloat: Numeric { }
