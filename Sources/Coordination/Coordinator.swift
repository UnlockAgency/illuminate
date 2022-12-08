//
//  Coordinator.swift
//
//
//  Created by Bas van Kuijck on 2022/06/23.
//

import Foundation
import UIKit
import Combine

public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var parentCoordinator: Coordinator? { get set }
    var transition: Transition { get set }    
    static var navigationControllerType: UINavigationController.Type { get set }

    @MainActor
    func start()
    
    @MainActor
    func start(coordinator: Coordinator, transition: Transition)
    func removeChildCoordinators()
}

private var navigationControllerKey: UInt8 = 0
private var transitionKey: UInt8 = 0

public extension Coordinator {
    
    var rootCoordinator: Coordinator {
        var coordinator: Coordinator = self
        while coordinator.parentCoordinator != nil {
            coordinator = coordinator.parentCoordinator!
        }
        return coordinator
    }
    
    var transition: Transition {
        get {
            if let customTransition = objc_getAssociatedObject(self, &transitionKey) as? Transition {
                return customTransition
            }
            let newTransition = Transition()
            self.transition = newTransition
            return newTransition
        }
        set {
            objc_setAssociatedObject(self, &transitionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var navigationController: UINavigationController {
        get {
            if let navController = objc_getAssociatedObject(self, &navigationControllerKey) as? UINavigationController {
                return navController

            } else if let parentCoordinator {
                return parentCoordinator.navigationController

            } else {
                let newNavigationController = Self.navigationControllerType.init() // swiftlint:disable:this explicit_init
                self.navigationController = newNavigationController
                return newNavigationController
            }
        }

        set {
            // Assign, because we don't want any retain cycles for (manually) set NavigationControllers
            objc_setAssociatedObject(self, &navigationControllerKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @MainActor
    func start(coordinator: Coordinator) {
        start(coordinator: coordinator, transition: .init())
    }
}

public extension AnyPublisher where Output == Void, Failure == Never {
    @MainActor
    func start(coordinator: @autoclosure @escaping (() -> Coordinator), from parentCoordinator: Coordinator, transition: Transition = Transition()) -> AnyCancellable {
        return sink { [weak parentCoordinator, coordinator, transition] _ in
            parentCoordinator?.start(coordinator: coordinator(), transition: transition)
        }
    }
}
