//
//  UnknownableEnum.swift
//
//
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

public protocol UnknownableEnum: RawRepresentable {
    static var unknown: Self { get }
}

/// Implementing the `UnknownableEnum` protocol on a Decodable enum
/// will result in an `.unknown` case when parsing fails
public extension UnknownableEnum where Self: Decodable, Self.RawValue: Decodable {
    init(from decoder: Decoder) throws {
        self = (try? Self(rawValue: decoder.singleValueContainer().decode(RawValue.self))) ?? Self.unknown
    }
}
