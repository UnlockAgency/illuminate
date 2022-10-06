//
//  Filterable.swift
//
//
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

public protocol Unknownable {
    var isUnknown: Bool { get }
}

public protocol FilterStrategy {
    associatedtype Value: Codable
    static func filter(_ element: Value) -> Bool
}

public struct UnknownEnumFilterableStrategy<T>: FilterStrategy where T: UnknownableEnum & Codable, T.RawValue == String {
    public static func filter(_ element: T) -> Bool {
        return element != T.unknown
    }
}

public typealias UnknownEnumFilterable<T> = Filterable<UnknownEnumFilterableStrategy<T>> where T: UnknownableEnum & Codable, T.RawValue == String

public struct UnknownFilterableStrategy<T>: FilterStrategy where T: Unknownable & Codable {
    public static func filter(_ element: T) -> Bool {
        return !element.isUnknown
    }
}

public typealias UnknownFilterable<T> = Filterable<UnknownFilterableStrategy<T>> where T: Unknownable & Codable

@propertyWrapper
public struct Filterable<Strategy: FilterStrategy>: Codable {
    private(set) var value: [Strategy.Value]
    
    public var wrappedValue: [Strategy.Value] {
        get {
            value.filter { Strategy.filter($0) }
        }
        set {
            value = newValue
        }
    }
    
    public init(wrappedValue: [Strategy.Value]) {
        self.value = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode([Strategy.Value].self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
