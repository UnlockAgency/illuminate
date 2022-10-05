//
//  Transition.swift
//
//
//  Created by Bas van Kuijck on 2022/06/23.
//

import Foundation

public struct Transition {
    public let type: TranstionType
    public let animated: Bool

    public init(type: TranstionType = .push, animated: Bool = true) {
        self.type = type
        self.animated = animated
    }
}

public enum TranstionType {
    // Simply push in the current Navigation Controller
    case push

    // Resets the Navigation Controller's view stack => `viewControllers = [ viewController ]`
    // Backwards will make the viewcontroller's navigationstack pop
    case reset(backwards: Bool = false)

    // Present the ViewController
    // true = Present with a new UINavigationController (defaults to `false`)
    case present(_ presentSettings: PresentSettings = .init())

    // Do nothing
    case none
}

public struct PresentSettings {
    public let inNewNavigationController: Bool
    public let fullScreen: Bool

    public init(inNewNavigationController: Bool = true, fullScreen: Bool = false) {
        self.inNewNavigationController = inNewNavigationController
        self.fullScreen = fullScreen
    }
}
