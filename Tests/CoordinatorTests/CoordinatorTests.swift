//
//  CoordinatorTests.swift
//  
//
//  Created by Bas van Kuijck on 16/02/2023.
//

import Foundation

import XCTest
import Nimble
import Combine
@testable import IlluminateCoordination

@objc
private protocol OutwardProtocol {
    func doSomething()
}

@objc
private protocol InwardProtocol {
    func doSomethingInward()
}

private class Root1Coordinator: BaseCoordinator, OutwardProtocol {
    var didSomething = false
    func doSomething() {
        didSomething = true
    }
    
}

private class Child1Coordinator: BaseCoordinator {
    
}

private class Child2Coordinator: BaseCoordinator, InwardProtocol {
    var didSomething = false
    func doSomethingInward() {
        didSomething = true
    }
}

private class Child3Coordinator: BaseCoordinator {
    
}

private class SubChild1Coordinator: BaseCoordinator, InwardProtocol {
    var didSomething = false
    func doSomethingInward() {
        didSomething = true
    }
}

class CoordinatorTests: XCTestCase {
    
    @MainActor
    func testBubblingOutward() async throws {
        let rootCoordinator = Root1Coordinator()
        let childCoordinator1 = Child1Coordinator()
        rootCoordinator.start(coordinator: childCoordinator1)
        
        let childCoordinator2 = Child2Coordinator()
        rootCoordinator.start(coordinator: childCoordinator2)
        
        let child3Coordinator = Child3Coordinator()
        rootCoordinator.start(coordinator: child3Coordinator)
        
        let subCoordinator = SubChild1Coordinator()
        child3Coordinator.start(coordinator: subCoordinator)
        subCoordinator.bubble(direction: .outward, type: OutwardProtocol.self, selector: #selector(OutwardProtocol.doSomething))
        expect(rootCoordinator.didSomething) == true
    }
    
    @MainActor
    func testBubblingInwardHalt() throws {
        let rootCoordinator = Root1Coordinator()
        let childCoordinator1 = Child1Coordinator()
        rootCoordinator.start(coordinator: childCoordinator1)
        
        let child2Coordinator = Child2Coordinator()
        rootCoordinator.start(coordinator: child2Coordinator)
        
        let child3Coordinator = Child3Coordinator()
        rootCoordinator.start(coordinator: child3Coordinator)
        
        let subCoordinator = SubChild1Coordinator()
        child3Coordinator.start(coordinator: subCoordinator)
        
        rootCoordinator.bubble(direction: .inward(halt: true), type: InwardProtocol.self, selector: #selector(InwardProtocol.doSomethingInward))
        expect(child2Coordinator.didSomething) == true
        expect(subCoordinator.didSomething) == false
    }
    
    @MainActor
    func testBubblingInwardNoHalt() throws {
        let rootCoordinator = Root1Coordinator()
        let childCoordinator1 = Child1Coordinator()
        rootCoordinator.start(coordinator: childCoordinator1)
        
        let child2Coordinator = Child2Coordinator()
        rootCoordinator.start(coordinator: child2Coordinator)
        
        let child3Coordinator = Child3Coordinator()
        rootCoordinator.start(coordinator: child3Coordinator)
        
        let subCoordinator = SubChild1Coordinator()
        child3Coordinator.start(coordinator: subCoordinator)
        
        rootCoordinator.bubble(direction: .inward(halt: false), type: InwardProtocol.self, selector: #selector(InwardProtocol.doSomethingInward))
        expect(child2Coordinator.didSomething) == true
        expect(subCoordinator.didSomething) == true
    }
}
