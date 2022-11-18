//
//  RoutingTests.swift
//  
//
//  Created by Bas van Kuijck on 18/11/2022.
//

import XCTest
import Nimble
import Combine
@testable import IlluminateRouting

private struct DashboardRoute: Route {
    let value: String
    static func handle(url: URL) -> Self? {
        
        guard let path = getPath(from: url),
              path.hasPrefix("/dashboard") else {
            return nil
        }
        
        return DashboardRoute(value: path)
    }
}

private struct FooRoute: Route {
    let value: String
    static func handle(url: URL) -> Self? {
        
        guard let path = getPath(from: url),
              path.hasPrefix("/foo") else {
            return nil
        }
        
        return FooRoute(value: path)
    }
}

class RoutingTests: XCTestCase {
    
    let routingManager = RoutingManager()
    var cancellables = Set<AnyCancellable>()
    
    func testDashboardRoute() {
        let expectation = expectation(description: "dashboard")
        routingManager.registerRoutes(DashboardRoute.self, FooRoute.self)
        
        routingManager.handle(url: URL(string: "app://dashboard")!)
        
        routingManager.publisher(for: DashboardRoute.self)
            .sink { value in
                expect(value) == "/dashboard"
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        routingManager.publisher(for: FooRoute.self)
            .sink { _ in
                XCTAssertTrue(false, "Should not reach this")
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 10)
    }
    
    func testUnregisterRoute() {
        let expectation = expectation(description: "dashboard")
        routingManager.registerRoutes(DashboardRoute.self, FooRoute.self)
        routingManager.unregisterRoutes(DashboardRoute.self)
        
        routingManager.handle(url: URL(string: "app://dashboard")!)
        
        Publishers.Merge(
            routingManager.publisher(for: FooRoute.self).map { _ in },
            routingManager.publisher(for: DashboardRoute.self).map { _ in }
        ).sink { _ in
            XCTAssertTrue(false, "Should not reach this")
        }
        .store(in: &cancellables)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.2)
    }
    
}

