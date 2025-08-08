 //
//  Transition.swift
//
//
//  Created by Bas van Kuijck on 2022/06/23.
//

import Foundation
@preconcurrency import UIKit

public struct Transition: Sendable {
    public let type: TranstionType
    public let animated: Bool

    public init(type: TranstionType = .push, animated: Bool = true) {
        self.type = type
        self.animated = animated
    }
}

public enum TranstionType: Sendable {
    // Simply push in the current Navigation Controller
    case push

    // Resets the Navigation Controller's view stack => `viewControllers = [ viewController ]`
    // Backwards will make the viewcontroller's navigationstack pop
    case reset(backwards: Bool = false)

    // Present the ViewController
    // true = Present with a new UINavigationController (defaults to `false`)
    case present(_ presentSettings: PresentSettings = .init())
    
    // A  custom transition animation
    case custom(animator: CustomTransitionAnimator & UIViewControllerAnimatedTransitioning)

    // Do nothing
    case none
}

public struct PresentSettings: Sendable {
    public let inNewNavigationController: Bool
    public let fullScreen: Bool

    public init(inNewNavigationController: Bool = true, fullScreen: Bool = false) {
        self.inNewNavigationController = inNewNavigationController
        self.fullScreen = fullScreen
    }
}

public protocol CustomTransitionAnimator: Sendable {
    
}

nonisolated(unsafe) private var customTransitionAnimatorKey: UInt8 = 0

public extension CustomTransitionAnimator {
    var isPushing: Bool {
        get {
            return objc_getAssociatedObject(self, &customTransitionAnimatorKey) as? Bool == true
        }
        set {
            objc_setAssociatedObject(self, &customTransitionAnimatorKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
