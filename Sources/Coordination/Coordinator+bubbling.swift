//
//  Coordinator+bubbling.swift
//
//
//  Created by Bas van Kuijck on 2022/06/23.
//

import Foundation
import Combine

public extension Coordinator {
    /// Bubbling
    ///
    /// With bubbling, the event is first captured and handled by the innermost element and then propagated to outer elements.
    ///
    /// ```
    ///                  ^
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
    ///   - type: `T.Type`. What kind of Listener (protocol) should the Coordinate inherit?
    ///   - handler: `((T) -> Void)` Call this handler on each of the bubbled Coordinates

    func bubble<T>(type: T.Type, handler: ((T) -> Void)) {
        var coordinator: Coordinator? = self

        while coordinator != nil {
            if let listener = coordinator as? T {
                handler(listener)
            }
            coordinator = coordinator?.parentCoordinator
        }
    }

    func bubble<T>(type: T.Type, selector: Selector) {
        var coordinator: Coordinator? = self

        while coordinator != nil {
            let anyObject = coordinator as AnyObject
            if anyObject is T && anyObject.responds(to: selector) {
                _ = anyObject.perform(selector)
            }
            coordinator = coordinator?.parentCoordinator
        }
    }
}

public extension Publisher where Output == Void {
    func bubble<T>(coordinator: Coordinator, type: T.Type, selector: Selector) -> AnyCancellable {
        return sink(receiveCompletion: { _ in
            
        }, receiveValue: { [weak coordinator] _ in
            coordinator?.bubble(type: type, selector: selector)
        })
    }
}
