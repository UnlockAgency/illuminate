//
//  URLCodable.swift
//  Illuminate
//
//  Created by Bas van Kuijck on 17/10/2024.
//
import Foundation

public extension KeyedDecodingContainer {
    func decode(_ type: URL.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> URL {
        let decodedValue = try self.decode(String.self, forKey: key)
        if let url = URL(string: decodedValue) {
            return url
        }
        throw(DecodingError.typeMismatch(URL.self, DecodingError.Context(codingPath: [key], debugDescription: "Failed to transform the underling string(\(decodedValue)) into URL")))
    }
    
    func decodeIfPresent(_ type: URL.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> URL? {
        if let decodedValue = try self.decodeIfPresent(String.self, forKey: key), let url = URL(string: decodedValue)  {
            return url
        }
        return nil
    }
}

public extension KeyedEncodingContainer {
    mutating func encode(_ value: URL, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try self.encode(value.absoluteString, forKey: key)
    }
    
    mutating func encodeIfPresent(_ value: URL?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try self.encodeIfPresent(value?.absoluteString, forKey: key)
    }
}
