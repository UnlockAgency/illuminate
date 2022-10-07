//
//  DefaultCodable.swift
//
//
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol DefaultCodableStrategy {
    associatedtype RawValue: Codable
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

public struct DefaultZeroStrategy<T: Numeric & Codable>: DefaultCodableStrategy {
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

public struct DefaultEmptyStrategy<T>: DefaultCodableStrategy where T: Codable & RangeReplaceableCollection {
    public static var defaultValue: T {
        return T()
    }
}

public struct DefaultEmptyDictionaryStrategy<T: Codable & Hashable, U: Codable>: DefaultCodableStrategy {
    public static var defaultValue: [T: U] {
        return [:]
    }
}

public struct DefaultNilStrategy<T: Codable>: DefaultCodableStrategy {
    public static var defaultValue: T? {
        nil
    }
}

public protocol DefaultValueProvider {
    associatedtype Value = Equatable & Codable
    static var defaultValue: Value { get }
}

/// If decoding returns `nil` or throws an error: Fallback to an empty array
public typealias DefaultEmptyDictionary<T, U> = DefaultCodable<DefaultEmptyDictionaryStrategy<T, U>> where T: Codable & Hashable, U: Codable

/// If decoding returns `nil` or throws an error: Fallback to `nil`
public typealias DefaultNil<T> = DefaultCodable<DefaultNilStrategy<T>> where T: Codable

/// If decoding returns `nil` or throws an error: Fallback to `false`
public typealias DefaultFalse = DefaultCodable<DefaultFalseStrategy>

/// If decoding returns `nil` or throws an error: Fallback to and empty string (`""`) or array (`[]`)
public typealias DefaultEmpty<T> = DefaultCodable<DefaultEmptyStrategy<T>> where T: Codable & RangeReplaceableCollection

/// If decoding returns `nil` or throws an error: Fallback to `true`
public typealias DefaultTrue = DefaultCodable<DefaultTrueStrategy>

/// If decoding returns `nil` or throws an error: Fallback to `0`
public typealias DefaultZero<T> = DefaultCodable<DefaultZeroStrategy<T>> where T: Numeric & Codable

/// If decoding returns `nil` or throws an error: Fallback to the first enum element
public enum FirstEnumCase<A>: DefaultValueProvider where A: Codable, A: Equatable, A: CaseIterable {
    public static var defaultValue: A { A.allCases.first! }
}

/// If decoding returns `nil` or throws an error: Fallback to the last enum element
public enum LastEnumCase<A>: DefaultValueProvider where A: Codable, A: Equatable, A: CaseIterable {
    public static var defaultValue: A { A.allCases[(A.allCases.count - 1) as! A.AllCases.Index] } // swiftlint:disable:this force_cast
}

@propertyWrapper
public struct DefaultCodable<Strategy: DefaultCodableStrategy>: Codable, CustomDebugStringConvertible {
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
    func decode<P>(_: DefaultCodable<P>.Type, forKey key: Key) throws -> DefaultCodable<P> {
        if let value = try decodeIfPresent(DefaultCodable<P>.self, forKey: key) {
            return value
        } else {
            return DefaultCodable(wrappedValue: P.defaultValue)
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
