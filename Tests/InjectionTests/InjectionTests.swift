//
//  PleinCoreTests.swift
//
//
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

import XCTest
import Nimble
import Combine
import Swinject
@testable import IlluminateInjection

private class InjectedServiceMixed {
    let uid = UUID().uuidString
    @Injected(resolver: PleinInjectedTests.resolver) var sub1: InjectedSubService
    @LazyInjected(resolver: PleinInjectedTests.resolver, name: "lazy") var sub2: InjectedSubService
}

private class InjectedServiceLazy {
    let uid = UUID().uuidString
    @LazyInjected(resolver: PleinInjectedTests.resolver, name: "lazy") var sub: InjectedSubService
}

private class InjectedServicePlain {
    let uid = UUID().uuidString
    @Injected(resolver: PleinInjectedTests.resolver) var sub: InjectedSubService
}

private class InjectedSubService {
    let uid = UUID().uuidString
}

class PleinInjectedTests: XCTestCase {
    static let resolver = Container()
    
    override func setUp() {
        super.setUp()
        let subService = InjectedSubService()
        PleinInjectedTests.resolver.register(InjectedSubService.self) { _ in subService }
        
        let serviceLazy = InjectedServiceLazy()
        let servicePlain = InjectedServicePlain()
        PleinInjectedTests.resolver.register(InjectedServiceLazy.self) { _ in serviceLazy }
        PleinInjectedTests.resolver.register(InjectedServicePlain.self) { _ in servicePlain }
        
        let serviceMixed1 = InjectedServiceMixed()
        PleinInjectedTests.resolver.register(InjectedServiceMixed.self) { _ in serviceMixed1 }
        let serviceMixed2 = InjectedServiceMixed()
        PleinInjectedTests.resolver.register(InjectedServiceMixed.self, name: "mixed2") { _ in serviceMixed2 }
        
        PleinInjectedTests.resolver.register(InjectedSubService.self, name: "lazy") { _ in InjectedSubService() }
    }
    
    func testInjected() {
        guard let service1a = PleinInjectedTests.resolver.resolve(InjectedServiceMixed.self),
        let service1b = PleinInjectedTests.resolver.resolve(InjectedServiceMixed.self, name: "mixed2") else {
            XCTAssert(false, "No InjectedServiceMixed resolved")
            return
        }
        XCTAssertNotEqual(service1a.uid, service1b.uid)
        XCTAssertEqual(service1a.sub1.uid, service1a.sub1.uid)
        XCTAssertEqual(service1a.sub2.uid, service1a.sub2.uid)
        XCTAssertNotEqual(service1a.sub1.uid, service1b.sub2.uid)
    }
    
    func testLazyInjected() {
        // Calling this service should not result into a crash, since the subservice is LazyInjected
        guard let service = PleinInjectedTests.resolver.resolve(InjectedServiceLazy.self) else {
            XCTAssert(false, "No InjectedService2 resolved")
            return
        }
        XCTAssertNotEqual(service.uid, "")
        XCTAssertNotEqual(service.sub.uid, "")
    }
    
    func testSameInjected() {
        guard let serviceMixed = PleinInjectedTests.resolver.resolve(InjectedServiceMixed.self),
              let servicePlain = PleinInjectedTests.resolver.resolve(InjectedServicePlain.self) else {
            XCTAssert(false, "No InjectedService1, InjectedService3 resolved")
            return
        }
        XCTAssertEqual(serviceMixed.sub1.uid, servicePlain.sub.uid)
    }
    
}
