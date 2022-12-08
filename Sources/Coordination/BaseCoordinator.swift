//
//  BaseCoordinator.swift
//
//
//  Created by Bas van Kuijck on 2022/06/23.
//

import Foundation
import Dysprosium
import UIKit
import Combine
import SwiftUI

private var coordinatorKey: UInt8 = 0

private class BarButtonItem: UIBarButtonItem {
    private var actionHandler: (() -> Void)?

    convenience init(barButtonSystemItem: UIBarButtonItem.SystemItem, actionHandler: (() -> Void)?) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: #selector(BarButtonItem.barButtonItemPressed))
        target = self
        self.actionHandler = actionHandler
    }

    @objc
    private func barButtonItemPressed(sender: UIBarButtonItem) {
        actionHandler?()
    }
}

open class BaseCoordinator: Coordinator, DysprosiumCompatible {

    public lazy var cancellables = Set<AnyCancellable>()
    
    public static var navigationControllerType: UINavigationController.Type = UINavigationController.self

    // Weak references to the coordinators
    // We use AnyObject, because `Coordinator` is not a class, but a protocol
    // And we cannot (and will not) add @objc to the Coordinator protocol
    private(set) var childCoordinators = NSHashTable<AnyObject>(options: .weakMemory)

    public weak var parentCoordinator: Coordinator?

    public init() {
    }

    open func start() {
    }

    open func start(coordinator: Coordinator, transition: Transition) {
        childCoordinators.add(coordinator as AnyObject)
        coordinator.transition = transition
        coordinator.parentCoordinator = self
        coordinator.start()
    }

    open func removeChildCoordinators() {
        childCoordinators.allObjects
            .compactMap { $0 as? Coordinator }
            .forEach { $0.removeChildCoordinators() }
        childCoordinators.removeAllObjects()
    }

    /// Factory function
    ///
    /// - Parameters:
    ///   - type: `Controller.Type`. The UIViewController class (e.g. NewsViewController.self)
    ///   - viewModel: `Controller.ViewModelType` A ViewModel, defaults to `Controller.ViewModelType()` (a new ViewModel will be initialized)
    ///
    /// - Returns: `Controller`. A UIViewController conforming to `ViewModelControllable`
    @MainActor
    @discardableResult
    open func displayViewController<Controller: ViewModelControllable>(type: Controller.Type, viewModel: Controller.ViewModelType = Controller.ViewModelType()) -> Controller where Controller: UIViewController {
        let viewController = Controller(viewModel: viewModel)

        // We want to retain this coordinator during the ViewModel's lifetime
        objc_setAssociatedObject(viewModel, &coordinatorKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        show(viewController: viewController)

        return viewController
    }
    
    /// Factory function
    ///
    /// - Parameters:
    ///   - type: `ViewType.Type`. The SwiftUI.View class (e.g. NewsContentView.self)
    ///   - viewModel: `ViewType.ViewModelType` A ViewModel, defaults to `ViewType.ViewModelType()` (a new ViewModel will be initialized)
    ///
    /// - Returns: A `UIHostingController<ViewType>`. A `UIHostingController` where `ViewType` conforms to `ViewModelControllable`
    ///
    @discardableResult
    @MainActor
    open func displayHostingController<ViewType: ViewModelControllable, Controller, V>(
        type: ViewType.Type,
        viewModel: ViewType.ViewModelType = ViewType.ViewModelType(),
        controller builder: (ViewType) -> Controller
    ) -> Controller where Controller: UIHostingController<V> {
        let view = ViewType(viewModel: viewModel)
        let controller = builder(view)
        
        // The coordinator is retained during the BaseHostingController's lifetime
        objc_setAssociatedObject(controller, &coordinatorKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // The viewmodel in its turn is retained during the coordinator's lifetime
        objc_setAssociatedObject(self, &coordinatorKey, viewModel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        show(viewController: controller)
        
        return controller
    }
    
    @discardableResult
    @MainActor
    open func displayHostingController<ViewType: ViewModelControllable>(
        type: ViewType.Type,
        viewModel: ViewType.ViewModelType = ViewType.ViewModelType()
    ) -> UIHostingController<ViewType> {
        let view = ViewType(viewModel: viewModel)
        return displayHostingController(type: type, viewModel: viewModel) { _ in
            return UIHostingController(rootView: view)
        }
    }
    
    private func show(viewController: UIViewController) {
        switch transition.type {
        case .present(let settings):
            let animated = transition.animated
            if !settings.inNewNavigationController {
                if settings.fullScreen {
                    viewController.modalPresentationStyle = .fullScreen
                }
                navigationController.present(viewController, animated: animated)
                return
            }

            let newNavigationController = Self.navigationControllerType.init(rootViewController: viewController) // swiftlint:disable:this explicit_init

            if settings.fullScreen {
                newNavigationController.modalPresentationStyle = .fullScreen
            }
            navigationController.present(newNavigationController, animated: animated)
            navigationController = newNavigationController

            let item = BarButtonItem(barButtonSystemItem: .close) { [weak newNavigationController] in
                newNavigationController?.dismiss(animated: animated)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak viewController] in
                viewController?.navigationItem.rightBarButtonItem = item
            }
        case .push:
            navigationController.pushViewController(viewController, animated: transition.animated)

        case .reset(let backwards):
            // Reset the parentCoordinator, since we're breaking up the navigation stack
            parentCoordinator = rootCoordinator
            if backwards, let lastViewController = navigationController.viewControllers.last, transition.animated {
                let viewControllers = [ viewController, lastViewController ]
                navigationController.setViewControllers(viewControllers, animated: false)
                navigationController.popViewController(animated: true)
            } else {
                navigationController.setViewControllers([ viewController ], animated: transition.animated)
            }

        case .none:
            break
        }
    }

    deinit {
        deallocated()
    }
}
