//
//  ConvertorTests.swift
//
//
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

import XCTest
import Nimble
import Combine
@testable import IlluminateCodable

// MARK: - Helpers
// --------------------------------------------------------

private struct StringToDoubleConvertor: ConvertorValueProvider {
    static var defaultValue: Double {
        return 0
    }
    
    static func decode(from value: String) -> Double {
        return Double(value) ?? 0
    }
    
    static func encode(from value: Double) -> String {
        return "\(value)"
    }
}

private struct TestModel: Codable {
    @CodableConvertor<StringToDoubleConvertor>
    var price: Double = 0
    
    var name: String = ""
}

// MARK: - Tests
// --------------------------------------------------------

class ConvertorTests: XCTestCase {
    func testConvertorPriceString() {
        do {
            let data = #"{ "price": "3.99", "name": "Banana" }"#.data(using: .utf8)!
            let testModel = try JSONDecoder().decode(TestModel.self, from: data)
            expect(testModel.price) == 3.99
            expect(testModel.name) == "Banana"
            
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testConvertorPriceDouble() {
        do {
            let data = #"{ "price": 5.11, "name": "Apple" }"#.data(using: .utf8)!
            let testModel = try JSONDecoder().decode(TestModel.self, from: data)
            expect(testModel.price) == 5.11
            expect(testModel.name) == "Apple"
            
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testConvertorPriceNil() {
        do {
            let data = #"{ "price": null, "name": "Pear" }"#.data(using: .utf8)!
            let testModel = try JSONDecoder().decode(TestModel.self, from: data)
            expect(testModel.price) == 0
            expect(testModel.name) == "Pear"
            
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
}
