//
//  AppCoordinator.swift
//  IluminateExample
//
//  Created by Bas van Kuijck on 09/02/2024.
//

import Foundation
import IlluminateCoordination
import UIKit

class AppCoordinator: TabbarCoordinator {
    
    lazy var mainController = MainViewController()
    
    @MainActor
    func setup(with window: UIWindow?) {
        navigationController = mainController.mainNavigationController
        
        window?.rootViewController = mainController
        window?.makeKeyAndVisible()
        mainController.appCoordinator = self
    }
    
    @MainActor
    override func start() {
        startTab(coordinator: View1Coordinator(title: "Tab 1, view 1", color: .blue), at: 0, reset: false)
    }
}
