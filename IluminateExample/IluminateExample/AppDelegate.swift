//
//  AppDelegate.swift
//  IluminateExample
//
//  Created by Bas van Kuijck on 09/02/2024.
//

import UIKit
import IlluminateCoordination

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
    lazy var coordinator = AppCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        setupAppCoordinator()
        return true
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
    }
    
    private func setupAppCoordinator() {
        coordinator.setup(with: window)
        coordinator.start()
    }
}
