//
//  Coordinator+bubbling.swift
//
//
//  Created by Bas van Kuijck on 2022/06/23.
//

import Foundation
import Combine

public enum CoordinatorBubbleDirection {
    /// Bubbles to underlying children. And halts if a selector / type is reached.
    case inward(halt: Bool)
    
    /// Bubbles to its parents
    case outward
}

public extension Coordinator {
    /// Bubbling
    ///
    /// With bubbling, the event is first captured and handled by the innermost element and then propagated to outer elements.
    ///
    /// ```
    ///                  .
    ///                 / \
    ///                /_ _\
    /// ╭──────────────┄│ |┄──╮
    /// │ element1      │ │   │
    /// │   ╭-─────────┄│ │┄╮ │
    /// │   │ element2  └┄┘ │ │
    /// │   ╰───────────────╯ │
    /// ╰─────────────────────╯
    /// ```
    ///
    /// By using bubbling in Coordinates, you can bubble an event from the inner element to the outmost outer element.
    ///
    /// - Parameters:
    ///   - direction: `CoordinatorBubbleDirection`. The direction. Default: `.outward`
    ///   - type: `T.Type`. What kind of Listener (protocol) should the Coordinate inherit?
    ///   - handler: `((T) -> Void)` Call this handler on each of the bubbled Coordinates

    @discardableResult
    func bubble<T>(direction: CoordinatorBubbleDirection = .outward, type: T.Type, handler: ((T) -> Void)) -> Bool {
        var found = false
        
        @discardableResult
        func perform(coordinator aCoordinator: Coordinator) -> Bool {
            if let listener = aCoordinator as? T {
                handler(listener)
                found = true
                return true
            }
            return false
        }
        
        switch direction {
        case .outward:
            var coordinator: Coordinator? = self
            
            while coordinator != nil {
                perform(coordinator: coordinator!)
                coordinator = coordinator?.parentCoordinator
            }
        case .inward(let halt):
            func bubbleFunc(coordinator: Coordinator) {
                for child in coordinator.children {
                    if perform(coordinator: child), halt {
                        return
                    }
                    bubbleFunc(coordinator: child)
                }
            }
            bubbleFunc(coordinator: self)
        }
        return found
    }

    @discardableResult
    func bubble<T>(direction: CoordinatorBubbleDirection = .outward, type: T.Type, selector: Selector) -> Bool {
        var found = false
        @discardableResult
        func perform(coordinator aCoordinator: Coordinator) -> Bool {
            let anyObject = aCoordinator as AnyObject
            if anyObject is T, anyObject.responds(to: selector) {
                _ = anyObject.perform(selector)
                found = true
                return true
            }
            return false
        }        
        
        switch direction {
        case .outward:
            var coordinator: Coordinator? = self
            
            while coordinator != nil {
                perform(coordinator: coordinator!)
                coordinator = coordinator?.parentCoordinator
            }
        case .inward(let halt):
            func bubbleFunc(coordinator: Coordinator) {
                for child in coordinator.children {
                    if perform(coordinator: child), halt {
                        return
                    }
                    bubbleFunc(coordinator: child)
                }
            }
            bubbleFunc(coordinator: self)
        }
        
        return found
    }
}

public extension Publisher where Output == Void {
    func bubble<T>(direction: CoordinatorBubbleDirection = .outward, coordinator: Coordinator, type: T.Type, selector: Selector) -> AnyCancellable {
        return sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak coordinator] _ in
            coordinator?.bubble(direction: direction, type: type, selector: selector)
        })
    }
}
