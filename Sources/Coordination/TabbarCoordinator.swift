//
//  TabbarCoordinator.swift
//
//
//  Created by Bas van Kuijck on 22/09/2022.
//

import Foundation
import UIKit

open class TabbarCoordinator: BaseCoordinator {
    private var activeIndex: Int?
    private var shouldReset = false
    private var cachedViewControllers: [Int: [UIViewController]] = [:]
    
    public func removeChildCoordinators(keepCurrent: Bool) {
        if !keepCurrent {
            activeIndex = nil
        }
        cachedViewControllers.removeAll()
        super.removeChildCoordinators()
    }
    
    override open func removeChildCoordinators() {
        removeChildCoordinators(keepCurrent: false)
    }
    
    /// This will open the navigation stack for a particular index
    ///
    /// - Parameters:
    ///   - coordinator: `Coordinator`
    ///   - index: `Int`
    ///   - reset: `Bool` (default: false). Set to true to always reset the navigation stack when the item is deselected
    @MainActor
    open func startTab(coordinator: Coordinator, at index: Int, reset: Bool = false) {
        defer {
            activeIndex = index
        }
        var animated = false
        if let activeIndex, !shouldReset {
            // Tapping on an active tab item will reset the navigation stack
            if index == activeIndex, !navigationController.viewControllers.isEmpty {
                cachedViewControllers.removeValue(forKey: index)
                animated = navigationController.viewControllers.count > 1
                
            } else {
                cachedViewControllers[activeIndex] = navigationController.viewControllers
            }
        }
        shouldReset = reset
        
        if let viewControllers = cachedViewControllers[index] {
            navigationController.setViewControllers(viewControllers, animated: false)
            // Currently visible viewcontrollers can be removed from the cache
            // That way the viewcontrollers that are popped will not stick in memory
            cachedViewControllers.removeValue(forKey: index)
            return
        }
        childCoordinators.add(coordinator as AnyObject)
        coordinator.transition = Transition(type: .reset(backwards: animated), animated: animated)
        coordinator.parentCoordinator = self
        coordinator.start()
    }
}
