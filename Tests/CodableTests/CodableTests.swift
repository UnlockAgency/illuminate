// CoreTests.swift
//
//
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation

import XCTest
import Nimble
import Combine
@testable import IlluminateCodable

// MARK: - Models
// --------------------------------------------------------

private enum Fruit: String, Codable, UnknownableEnum {
    case apple
    case banana
    case tangerine
    case unknown
}

private enum Vegetable: String, Codable {
    case tomato
    case patato
    case onion
}

private struct Salad: Codable, Equatable {
    let name: String
    
    @UnknownEnumFilterable<Fruit>
    var fruits: [Fruit] = []
    
    static func == (lhs: Salad, rhs: Salad) -> Bool {
        return lhs.name == rhs.name && lhs.fruits == rhs.fruits
    }
}

private struct NonBananaSalad: Codable, Equatable {
    let name: String
    
    @Filterable<BananaFilterableStrategy>
    var fruits: [Fruit] = []
    
    static func == (lhs: NonBananaSalad, rhs: NonBananaSalad) -> Bool {
        return lhs.name == rhs.name && lhs.fruits == rhs.fruits
    }
}

private struct SaladGroup: Codable {
    @DefaultNil<String>
    var name: String?
    
    @UnknownFilterable<SingleSalad>
    var salads: [SingleSalad]
}

private struct SingleSalad: Codable, Equatable, Unknownable {
    let name: String
    let fruit: Fruit
    
    var isUnknown: Bool {
        return fruit == .unknown
    }
    
    static func == (lhs: SingleSalad, rhs: SingleSalad) -> Bool {
        return lhs.name == rhs.name && lhs.fruit == rhs.fruit
    }
}

private struct BoolSalad: Codable, Equatable {
    let name: String
    
    @DefaultFalse
    var hasFruit: Bool
    
    static func == (lhs: BoolSalad, rhs: BoolSalad) -> Bool {
        return lhs.name == rhs.name
    }
}

private struct OptionalSalad: Codable, Equatable {
    @DefaultNil<String>
    var name: String?
    
    @DefaultNil<Vegetable>
    var vegetable: Vegetable?
    
    static func == (lhs: OptionalSalad, rhs: OptionalSalad) -> Bool {
        return lhs.name == rhs.name && lhs.vegetable == rhs.vegetable
    }
}

// MARK: - Strategies
// --------------------------------------------------------

private struct BananaFilterableStrategy: FilterStrategy {
    static func filter(_ element: Fruit) -> Bool {
        return element != .banana
    }
}

// MARK: - Tests
// --------------------------------------------------------

class CodableTests: XCTestCase {
    func testUknownEnum() {
        do {
            let data = #"[ "apple", "banana", "pear" ]"#.data(using: .utf8)!
            let fruits = try JSONDecoder().decode([Fruit].self, from: data)
            let expectedFruits: [Fruit] = [ .apple, .banana, .unknown ]
            XCTAssertEqual(fruits, expectedFruits)
            
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testUnknownFilterable() {
        do {
            let data = #"{ "name": "Fruit salad", "fruits": [ "apple", "banana", "pear" ] }"#.data(using: .utf8)!
            let salad = try JSONDecoder().decode(Salad.self, from: data)
            let expectedSalad = Salad(name: "Fruit salad", fruits: [.apple, .banana])
            XCTAssertEqual(salad, expectedSalad)
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testCustomFilterable() {
        do {
            let data = #"{ "name": "Non banana fruit salad", "fruits": [ "apple", "banana", "tangerine" ]}"#.data(using: .utf8)!
            let salad = try JSONDecoder().decode(NonBananaSalad.self, from: data)
            let expectedSalad = NonBananaSalad(name: "Non banana fruit salad", fruits: [.apple, .tangerine])
            XCTAssertEqual(salad, expectedSalad)
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testCustomSequenceFilterable() {
        do {
            // swiftlint:disable line_length
            let data = #"{ "name": "Salad group", "salads": [{ "name": "Apple fruit salad", "fruit": "apple" }, { "name": "Tangerine fruit salad", "fruit": "tangerine" }, { "name": "Pear fruit salad", "fruit": "pear" }]}"#.data(using: .utf8)!
            // swiftlint:enable line_length
            let saladGroup = try JSONDecoder().decode(SaladGroup.self, from: data)
            XCTAssertEqual(saladGroup.salads.count, 2)
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testOptionalCodable() {
        do {
            var data = #"{ "name": "Some salad", "vegetable": "carrot" }"#.data(using: .utf8)!
            var salad = try JSONDecoder().decode(OptionalSalad.self, from: data)
            var optionalSalad = OptionalSalad(name: "Some salad", vegetable: nil)
            XCTAssertEqual(salad, optionalSalad)
            
            data = #"{ "name": 1234, "vegetable": "tomato" }"#.data(using: .utf8)!
            salad = try JSONDecoder().decode(OptionalSalad.self, from: data)
            optionalSalad = OptionalSalad(name: nil, vegetable: .tomato)
            XCTAssertEqual(salad, optionalSalad)
            
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testDefaultCodable() {
        do {
            var data = #"{ "name": "Salad", "hasFruit": true }"#.data(using: .utf8)!
            var salad = try JSONDecoder().decode(BoolSalad.self, from: data)
            XCTAssertTrue(salad.hasFruit, "`\"hasFruit\": true` failed")

            data = #"{ "name": "Salad", "hasFruit": "something" }"#.data(using: .utf8)!
            salad = try JSONDecoder().decode(BoolSalad.self, from: data)
            XCTAssertFalse(salad.hasFruit, "`\"hasFruit\": \"something\"` failed")
            
            data = #"{ "name": "Salad", "hasVegetables": true }"#.data(using: .utf8)!
            salad = try JSONDecoder().decode(BoolSalad.self, from: data)
            XCTAssertFalse(salad.hasFruit, "`\"hasFruit\": nil` failed")
        } catch let error {
            XCTAssert(false, "\(error)")
        }
    }
}
