//
//  RoutingService.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import UserNotifications
import Combine

public protocol RoutingService: AnyObject {
    func handle(_ routable: Routable, dryRun: Bool) -> (any Route)?
    func handle(url: URL, dryRun: Bool) -> (any Route)?
#if canImport(UIKit)
    func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func handleNotification(response: UNNotificationResponse)
#endif
    
    func registerRoutes(_ routeTypes: [any Route.Type])
    func registerRoutes(_ routeTypes: any Route.Type...)
    
    func unregisterRoutes(_ routeTypes: [any Route.Type])
    func unregisterRoutes(_ routeTypes: any Route.Type...)
    
    @available(*, message: "Use `valuePublisher(for:)` instead")
    func publisher<T: Route>(for type: T.Type) -> AnyPublisher<T.ValueType, Never>
    
    
    /// Listen for route events
    ///
    /// **Example**
    /// ```
    /// routingService.valuePublisher(for: OAuthAuthenticatedRoute.self)
    ///     .sink { (value: OAuthAuthenticatedValue) in
    ///        // ... received value when 'xximo://oauth/authenticated' is openend
    ///     }.store(in: &cancellables)
    /// ```
    func valuePublisher<T: Route>(for type: T.Type) -> AnyPublisher<T.ValueType, Never>
    
    /// Listen for route events
    ///
    /// **Example**
    /// ```
    /// routingService.routePublisher(for: OAuthAuthenticatedRoute.self)
    ///     .sink { (value: OAuthAuthenticatedRoute) in
    ///        // ... 
    ///     }.store(in: &cancellables)
    /// ```
    func routePublisher<T: Route>(for type: T.Type) -> AnyPublisher<T, Never>
}

public extension RoutingService {
    func handle(_ routable: Routable) -> (any Route)? {
        return handle(routable, dryRun: false)
    }
    
    func handle(url: URL, dryRun: Bool) -> (any Route)? {
        return handle(url: url, dryRun: false)
    }
    
}
